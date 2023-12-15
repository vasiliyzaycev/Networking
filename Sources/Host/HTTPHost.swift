//
//  BaseHost.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 31.08.2021.
//

import Foundation

@NetworkingActor
public final class HTTPHost: Host {
  public typealias ErrorHandler = (Error, HTTPResponse) -> Void

  private let baseURL: URL
  private let gateway: Gateway
  private let options: HTTPOptions?
  private let errorHandler: ErrorHandler?

  public nonisolated init(
    baseURL: URL,
    gateway: Gateway,
    options: HTTPOptions? = nil,
    errorHandler: ErrorHandler? = nil
  ) {
    self.baseURL = baseURL
    self.gateway = gateway
    self.options = options
    self.errorHandler = errorHandler
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
    return try await handle(response, for: request)
  }
}

private extension HTTPHost {
  private func handle<Value>(
    _ response: HTTPResponse,
    for request: HTTPRequest<Value>
  ) async throws -> Value {
    do {
      return try await request.responseHandler(response)
    } catch {
      self.errorHandler?(error, response)
      throw error
    }
  }
}
