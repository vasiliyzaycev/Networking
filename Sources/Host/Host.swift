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
    complitionHandler: @escaping (Result<Value, Error>) -> Void
  ) -> CancelableTask
}

public extension Host {
  @discardableResult
  func push<Value>(
    request: HTTPRequest<Value>,
    complitionHandler: @escaping (Result<Value, Error>) -> Void
  ) -> CancelableTask {
    push(request: request, options: nil, complitionHandler: complitionHandler)
  }

  @discardableResult
  func push<Value>(
    request: HTTPRequest<Value>,
    requestOptions: HTTPRequestOptions?,
    complitionHandler: @escaping (Result<Value, Error>) -> Void
  ) -> CancelableTask {
    push(
      request: request,
      options: .init(requestOptions: requestOptions),
      complitionHandler: complitionHandler
    )
  }
}
