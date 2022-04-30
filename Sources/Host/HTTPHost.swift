//
//  BaseHost.swift
//  Networking
//
//  Created by Vasiliy Zaytsev on 31.08.2021.
//

import Foundation

public final class HTTPHost: Host {
  private let baseURL: URL
  private let gateway: Gateway
  private let options: HTTPOptions?
  private let tracker: TrackerProtocol?

  public init(
    baseURL: URL,
    gateway: Gateway,
    options: HTTPOptions? = nil,
    tracker: TrackerProtocol? = nil
  ) {
    self.baseURL = baseURL
    self.gateway = gateway
    self.options = options
    self.tracker = tracker
  }

  @discardableResult
  public func push<Value>(
    request: HTTPRequest<Value>,
    options extraOptions: HTTPOptions?,
    completionHandler: @escaping (Result<Value, Error>) -> Void
  ) -> CancelableTask {
    gateway.push(
      request: request,
      hostURL: baseURL,
      hostOptions: options,
      extraOptions: extraOptions
    ) { [weak self] result in
      guard let self = self else {
        assertionFailure("Dealloc host while processing request")
        return
      }
      completionHandler(self.handle(result, for: request))
    }
  }
}

private extension HTTPHost {
  private func handle<Value>(
    _ gatewayResult: Result<HTTPResponse, Error>,
    for request: HTTPRequest<Value>
  ) -> Result<Value, Error> {
    switch gatewayResult {
    case .success(let response):
      do {
        let value = try request.responseHandler(response)
        return .success(value)
      } catch {
        self.tracker?.track("Invalid server response!")
        return .failure(error)
      }
    case .failure(let error):
      return .failure(error)
    }
  }
}
