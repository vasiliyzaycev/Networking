//
//  Gateway.swift
//  NetworkService
//
//  Created by Vasiliy Zaytsev on 23.08.2021.
//

#if canImport(ObjcUtils)
import ObjcUtils
#endif

public final class HTTPGateway: NSObject, HTTPGatewayProtocol {
    public let session: URLSession

    private let options: HTTPRequestOptions?
    private let proxy: WeakProxy = WeakProxy.create()

    public init(
        configuration: URLSessionConfiguration = URLSessionConfiguration.default,
        options: HTTPRequestOptions? = nil,
        queue: OperationQueue = .main
    ) {
        self.options = options
        self.session = URLSession(
            configuration: configuration,
            delegate: proxy,
            delegateQueue: queue)
        super.init()
        proxy.object = self
    }

    @discardableResult
    public func push(
        request: HTTPRequestProtocol,
        hostURL: URL,
        hostOptions: HTTPRequestOptions?,
        extraOptions: HTTPRequestOptions?,
        complitionHandler: @escaping (Result<HTTPResponse, Error>) -> Void
    ) -> CancelableTask {
        let combinedOptions = combineOptions(
            gatewayOptions: options,
            hostOptions: hostOptions,
            extraOptions: extraOptions,
            requestOptions: request.options)
        do {
            let sessionTask = try request.taskFactory.task(
                request: createURLRequest(
                    hostURL: hostURL,
                    request: request,
                    options: combinedOptions),
                gateway: self)
            var responseData = Data()
            sessionTask.allowUntrustedSSLCertificates =
                hostOptions?.allowUntrustedSSLCertificates ?? false
            sessionTask.completionHandler = { [weak sessionTask] error in
                guard let sessionTask = sessionTask else { return }
                let responseURL = sessionTask.originalRequest?.url ?? hostURL
                if let error = error {
                    complitionHandler(.failure(
                        GatewayError.network(responseURL, error.localizedDescription)))
                } else if error == nil && sessionTask.response == nil {
                    complitionHandler(.failure(
                        GatewayError.server("Bad response from URL=\(responseURL)")))
                } else {
                    guard let metadata = sessionTask.response as? HTTPURLResponse else {
                        let error = GatewayError.server("URLResponse is nil or not HTTPURLResponse")
                        complitionHandler(.failure(error))
                        return
                    }
                    complitionHandler(.success(.init(data: responseData, metadata: metadata)))
                }
            }
            sessionTask.dataHandler = { data in
                responseData.append(data)
            }
            sessionTask.resume() //TODO: pos_start
            return CancelableTask { sessionTask.cancel() }
        } catch {
            return CancelableTask {}
        }
    }

    //TODO: support multiple invalidation
    public func invalidate(forced: Bool, complitionHandler: ((Error?) -> Void)?) {
        session.invalidateHandler = complitionHandler
        if (forced) {
            session.invalidateAndCancel()
        } else {
            session.finishTasksAndInvalidate()
        }
    }
}

extension WeakProxy: URLSessionDelegate {}

extension HTTPGateway: URLSessionDelegate {
    //TODO: support multiple invalidation
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        session.invalidateHandler?(error)
    }
}

extension HTTPGateway: URLSessionTaskDelegate {
    // Refuse redirection
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            task.allowUntrustedSSLCertificates,
            let serverTrust = challenge.protectionSpace.serverTrust
        else {
            completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
            return
        }
        completionHandler(
            URLSession.AuthChallengeDisposition.useCredential,
            URLCredential(trust: serverTrust))
    }

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        needNewBodyStream completionHandler: @escaping (InputStream?) -> Void
    ) {
        completionHandler(task.bodyStreamBuilder?())
    }

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        task.uploadProgress?(
            HTTPRequestProgress(
                ready: UInt64(totalBytesSent),
                total: UInt64(totalBytesExpectedToSend)))
    }

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        task.completionHandler?(error)
    }
}

extension HTTPGateway: URLSessionDataDelegate {
    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        completionHandler(URLSession.ResponseDisposition.allow)
    }

    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        dataTask.dataHandler?(data)
    }

    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        willCacheResponse proposedResponse: CachedURLResponse,
        completionHandler: @escaping (CachedURLResponse?) -> Void
    ) {
        completionHandler(nil)
    }
}

extension HTTPGateway: URLSessionDownloadDelegate {
    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        downloadTask.downloadCompletionHandler?(location)
    }

    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        downloadTask.downloadProgress?(
            HTTPRequestProgress(
                ready: UInt64(totalBytesWritten),
                total: UInt64(totalBytesExpectedToWrite)))
    }
}

private extension HTTPGateway {
    private func combineOptions(
        gatewayOptions: HTTPRequestOptions?,
        hostOptions: HTTPRequestOptions?,
        extraOptions: HTTPRequestOptions?,
        requestOptions: HTTPRequestOptions?
    ) -> HTTPRequestOptions? {
        var result = HTTPRequestOptions.merge(gatewayOptions, with: hostOptions)
        result = HTTPRequestOptions.merge(result, with: requestOptions)
        result = HTTPRequestOptions.merge(result, with: extraOptions)
        return result
    }

    private func createURLRequest(
        hostURL: URL,
        request: HTTPRequestProtocol,
        options: HTTPRequestOptions?
    ) -> URLRequest {
        let fullURL = hostURL.urlByAppending(options?.urlPath, query: options?.urlQuery)
        let responseTimeout = options?.responseTimeout ?? 30.0
        var urlRequest: URLRequest = URLRequest(
            url: fullURL,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: responseTimeout)
        urlRequest.httpMethod = request.method.name
        urlRequest.httpBody = options?.body
        urlRequest.allHTTPHeaderFields = options?.headers
        return urlRequest
    }
}
