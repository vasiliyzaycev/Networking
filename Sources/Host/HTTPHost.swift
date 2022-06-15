//
//  BaseHost.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 31.08.2021.
//

import Foundation

@NetworkingActor
final public class HTTPHost: Host {
  private let baseURL: URL
  private let gateway: Gateway
  private let options: HTTPOptions?
  private let tracker: TrackerProtocol?

  nonisolated public init(
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
    options extraOptions: HTTPOptions?
  ) async throws -> Value {
    let response = try await gateway.push(
      request: request,
      hostURL: baseURL,
      hostOptions: options,
      extraOptions: extraOptions
    )
    return try handle(response, for: request)
  }
}

private extension HTTPHost {
  private func handle<Value>(
    _ response: HTTPResponse,
    for request: HTTPRequest<Value>
  ) throws -> Value {
    do {
      return try request.responseHandler(response)
    } catch {
      self.tracker?.track("Invalid server response!")
      throw error
    }
  }
}
