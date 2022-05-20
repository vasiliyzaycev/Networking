//
//  Host.swift
//  NetworkService
//
//  Created by Vasiliy Zaytsev on 22.08.2021.
//

import Foundation

@NetworkingActor
public protocol Host {
  @discardableResult
  func push<Value>(
    request: HTTPRequest<Value>,
    options: HTTPOptions?
  ) async throws -> Value
}

public extension Host {
  @discardableResult
  func push<Value>(
    request: HTTPRequest<Value>
  ) async throws -> Value {
    try await push(request: request, options: nil)
  }

  @discardableResult
  func push<Value>(
    request: HTTPRequest<Value>,
    requestOptions: HTTPRequestOptions?
  ) async throws -> Value {
    try await push(
      request: request,
      options: .init(requestOptions: requestOptions)
    )
  }
}
