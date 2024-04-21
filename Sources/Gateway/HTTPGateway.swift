//
//  Gateway.swift
//  NetworkService
//
//  Created by Vasiliy Zaycev on 23.08.2021.
//

import Foundation

@NetworkingActor
public final class HTTPGateway: NSObject, Gateway {
  public let session: URLSession

  private let gatewayOptions: HTTPOptions?
  private nonisolated let proxy = WeakProxy()
  private let fileRemover: FileRemover
  private var invalidateTask: Task<Void, Error>?

  public nonisolated init(
    configuration: URLSessionConfiguration = .default,
    fileRemover: FileRemover = .default,
    options: HTTPOptions? = nil,
    queue: OperationQueue? = nil
  ) {
    self.gatewayOptions = options
    self.session = URLSession(configuration: configuration, delegate: proxy, delegateQueue: queue)
    self.fileRemover = fileRemover
    super.init()
    proxy.object = self
  }

  @discardableResult
  public func push(
    request: Request,
    hostURL: URL,
    hostOptions: HTTPOptions?,
    extraOptions: HTTPOptions?
  ) async throws -> HTTPResponse {
    guard invalidateTask == nil else { throw GatewayError.invalidGateway }
    let options = combineOptions(
      gatewayOptions: gatewayOptions,
      hostOptions: hostOptions,
      extraOptions: extraOptions,
      requestOptions: request.options
    )
    let sessionTask = try createSessionTask(hostURL, request, options?.requestOptions)
    if let simulatedResponse = simulatedResponse(request, hostURL, options) {
      return simulatedResponse
    }
    setupAllowingUntrustedSSLCertificates(for: sessionTask, options?.requestOptions)
    return try await fetchResponse(task: sessionTask, hostURL)
  }

  public func invalidate(forced: Bool) async throws {
    if let invalidateTask {
      return try await invalidateTask.value
    }
    self.invalidateTask = Task {
      try await withCheckedThrowingContinuation { continuation in
        invalidate(forced: forced, continuation)
      }
    }
    try await invalidateTask?.value
  }
}

extension WeakProxy: URLSessionDelegate {}

extension HTTPGateway: URLSessionDelegate {
  public func urlSession(
    _ session: URLSession,
    didBecomeInvalidWithError error: Error?
  ) {
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
      completionHandler(.performDefaultHandling, nil)
      return
    }
    completionHandler(.useCredential, URLCredential(trust: serverTrust))
  }

  public func urlSession(
    _ session: URLSession,
    task: URLSessionTask,
    needNewBodyStream completionHandler: @escaping @Sendable (InputStream?) -> Void
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
        ready: totalBytesSent,
        total: totalBytesExpectedToSend
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
    completionHandler(.allow)
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
    downloadTask.downloadedFile = downloadTask.fileHandler
      .map { fileHandler in
        Result { try fileHandler(location) }
      } ?? .failure(HTTPDownloadError.fileHandlerMissing)
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
        ready: totalBytesWritten,
        total: totalBytesExpectedToWrite
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
    let fullURL = hostURL.urlByAppending(options?.urlPath, queryItems: options?.queryItems)
    let responseTimeout = options?.responseTimeout ?? 30.0
    var urlRequest = URLRequest(
      url: fullURL,
      cachePolicy: .reloadIgnoringLocalCacheData,
      timeoutInterval: responseTimeout
    )
    urlRequest.httpMethod = request.method.name
    urlRequest.httpBody = options?.body
    urlRequest.allHTTPHeaderFields = options?.headers
    return urlRequest
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

  private func setupAllowingUntrustedSSLCertificates(
    for sessionTask: URLSessionTask,
    _ requestOptions: HTTPRequestOptions?
  ) {
    guard let allowUntrustedSSLCertificates = requestOptions?.allowUntrustedSSLCertificates
    else { return }
    sessionTask.allowUntrustedSSLCertificates = allowUntrustedSSLCertificates
  }

  private func fetchResponse(
    task sessionTask: URLSessionTask,
    _ hostURL: URL
  ) async throws -> HTTPResponse {
    try await { @Sendable in
      try await withTaskCancellationHandler { [unowned sessionTask] in
        try await withCheckedThrowingContinuation { [weak self] continuation in
          guard let self else {
            return continuation.resume(throwing: GatewayError.invalidGateway)
          }
          Task { @NetworkingActor in
            self.start(task: sessionTask, hostURL, continuation)
          }
        }
      } onCancel: { [unowned sessionTask] in
        sessionTask.cancel()
      }
    }()
  }

  private func start(
    task sessionTask: URLSessionTask,
    _ hostURL: URL,
    _ continuation: CheckedContinuation<HTTPResponse, Error>
  ) {
    var data = Data()
    sessionTask.dataHandler = { data.append($0) }
    sessionTask.completionHandler = { [unowned sessionTask, fileRemover] error in
      let responseURL = sessionTask.originalRequest?.url ?? hostURL
      let file = (sessionTask as? URLSessionDownloadTask)?.downloadedFile
      if let error {
        fileRemover.remove(file: file)
        continuation.resume(throwing: GatewayError.createGatewayError(error, url: responseURL))
        return
      }
      guard let response = sessionTask.response else {
        continuation.resume(throwing: GatewayError.systemEmptyResponse(url: responseURL))
        return
      }
      guard let response = response as? HTTPURLResponse else {
        // For HTTP request URLResponse is actually an instance of the HTTPURLResponse class.
        // See more at https://developer.apple.com/documentation/foundation/urlresponse
        preconditionFailure("URLResponse is not HTTPURLResponse")
      }
      continuation.resume(
        returning: HTTPResponse(data: data, downloadedFile: file, metadata: response)
      )
    }
    sessionTask.resume()
  }

  private func invalidate(forced: Bool, _ continuation: CheckedContinuation<Void, Error>) {
    session.invalidateHandler = { error in
      if let error {
        continuation.resume(throwing: error)
        return
      }
      continuation.resume()
    }
    if forced {
      session.invalidateAndCancel()
    } else {
      session.finishTasksAndInvalidate()
    }
  }
}
