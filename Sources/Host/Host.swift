//
//  Host.swift
//  NetworkService
//
//  Created by Vasiliy Zaytsev on 22.08.2021.
//

import Foundation

public protocol Host {
  @discardableResult
  func push<Value>(
    request: HTTPRequest<Value>,
    options: HTTPOptions?,
    completionHandler: @escaping (Result<Value, Error>) -> Void
  ) -> CancelableTask
}

public extension Host {
  @discardableResult
  func push<Value>(
    request: HTTPRequest<Value>,
    completionHandler: @escaping (Result<Value, Error>) -> Void
  ) -> CancelableTask {
    push(request: request, options: nil, completionHandler: completionHandler)
  }

  @discardableResult
  func push<Value>(
    request: HTTPRequest<Value>,
    requestOptions: HTTPRequestOptions?,
    completionHandler: @escaping (Result<Value, Error>) -> Void
  ) -> CancelableTask {
    push(
      request: request,
      options: .init(requestOptions: requestOptions),
      completionHandler: completionHandler
    )
  }
}
