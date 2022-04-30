//
//  Gateway.swift
//  NetworkService
//
//  Created by Vasiliy Zaytsev on 23.08.2021.
//

import Foundation

public final class HTTPGateway: NSObject, Gateway {
  public let session: URLSession

  private let gatewayOptions: HTTPOptions?
  private let proxy = WeakProxy()

  public init(
    configuration: URLSessionConfiguration = URLSessionConfiguration.default,
    options: HTTPOptions? = nil,
    queue: OperationQueue = .main
  ) {
    self.gatewayOptions = options
    self.session = URLSession(configuration: configuration, delegate: proxy, delegateQueue: queue)
    super.init()
    proxy.object = self
  }

  @discardableResult
  public func push(
    request: Request,
    hostURL: URL,
    hostOptions: HTTPOptions?,
    extraOptions: HTTPOptions?,
    completionHandler: @escaping (Result<HTTPResponse, Error>) -> Void
  ) -> CancelableTask {
    let options = combineOptions(
      gatewayOptions: gatewayOptions,
      hostOptions: hostOptions,
      extraOptions: extraOptions,
      requestOptions: request.options
    )
    let sessionTask: URLSessionTask
    do {
      sessionTask = try createSessionTask(hostURL, request, options?.requestOptions)
    } catch {
      completionHandler(.failure(error))
      return CancelableTask {}
    }
    if let simulatedResponse = simulatedResponse(request, hostURL, options) {
      completionHandler(.success(simulatedResponse))
      return CancelableTask {}
    }
    setupAllowingUntrustedSSLCertificates(for: sessionTask, options?.requestOptions)
    setupHandlers(for: sessionTask, hostURL, completionHandler)
    sessionTask.resume() // TODO: pos_start
    return CancelableTask { sessionTask.cancel() }
  }

  // TODO: support multiple invalidation
  public func invalidate(forced: Bool, completionHandler: ((Error?) -> Void)?) {
    session.invalidateHandler = completionHandler
    if forced {
      session.invalidateAndCancel()
    } else {
      session.finishTasksAndInvalidate()
    }
  }
}

extension WeakProxy: URLSessionDelegate {}

extension HTTPGateway: URLSessionDelegate {
  // TODO: support multiple invalidation
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
      URLCredential(trust: serverTrust)
    )
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
        total: UInt64(totalBytesExpectedToSend)
      )
    )
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
        total: UInt64(totalBytesExpectedToWrite)
      )
    )
  }
}

private extension HTTPGateway {
  private func combineOptions(
    gatewayOptions: HTTPOptions?,
    hostOptions: HTTPOptions?,
    extraOptions: HTTPOptions?,
    requestOptions: HTTPRequestOptions?
  ) -> HTTPOptions? {
    var result = HTTPOptions.merge(gatewayOptions, with: hostOptions)
    result = HTTPOptions.merge(result, with: requestOptions)
    result = HTTPOptions.merge(result, with: extraOptions)
    return result
  }

  private func createSessionTask(
    _ hostURL: URL,
    _ request: Request,
    _ requestOptions: HTTPRequestOptions?
  ) throws -> URLSessionTask {
    try request.taskFactory.createTask(
      request: createURLRequest(hostURL: hostURL, request: request, options: requestOptions),
      gateway: self
    )
  }

  private func createURLRequest(
    hostURL: URL,
    request: Request,
    options: HTTPRequestOptions?
  ) -> URLRequest {
    let fullURL = hostURL.urlByAppending(options?.urlPath, query: options?.urlQuery)
    let responseTimeout = options?.responseTimeout ?? 30.0
    var urlRequest = URLRequest(
      url: fullURL,
      cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      timeoutInterval: responseTimeout
    )
    urlRequest.httpMethod = request.method.name
    urlRequest.httpBody = options?.body
    urlRequest.allHTTPHeaderFields = options?.headers
    return urlRequest
  }

  private func setupAllowingUntrustedSSLCertificates(
    for sessionTask: URLSessionTask,
    _ requestOptions: HTTPRequestOptions?
  ) {
    guard let allowUntrustedSSLCertificates = requestOptions?.allowUntrustedSSLCertificates
    else { return }
    sessionTask.allowUntrustedSSLCertificates = allowUntrustedSSLCertificates
  }

  private func setupHandlers(
    for sessionTask: URLSessionTask,
    _ hostURL: URL,
    _ completionHandler: @escaping (Result<HTTPResponse, Error>) -> Void
  ) {
    var responseData = Data()
    sessionTask.dataHandler = { data in
      responseData.append(data)
    }
    sessionTask.completionHandler = { [weak sessionTask] error in
      guard let sessionTask = sessionTask else { return }
      let responseURL = sessionTask.originalRequest?.url ?? hostURL
      if let error = error {
        completionHandler(
          .failure(GatewayError.network(responseURL, error.localizedDescription))
        )
      } else if error == nil && sessionTask.response == nil {
        completionHandler(
          .failure(GatewayError.server("Bad response from URL=\(responseURL)"))
        )
      } else {
        guard let metadata = sessionTask.response as? HTTPURLResponse else {
          let error = GatewayError.server("URLResponse is nil or not HTTPURLResponse")
          completionHandler(.failure(error))
          return
        }
        completionHandler(.success(.init(data: responseData, metadata: metadata)))
      }
    }
  }

  private func simulatedResponse(
    _ request: Request,
    _ hostURL: URL,
    _ options: HTTPOptions?
  ) -> HTTPResponse? {
    options?.responseSimulator?.probeSimulation(
      for: request,
      hostURL: hostURL,
      options: options?.requestOptions
    )
  }
}
