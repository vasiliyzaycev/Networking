//
//  HTTPRequest.swift
//  NetworkService
//
//  Created by Vasiliy Zaycev on 22.08.2021.
//

import Foundation

public struct HTTPRequest<Value>: Request {
  public let method: HTTPMethod
  public let options: HTTPRequestOptions?
  public let responseHandler: HTTPResponseHandler<Value>
  public let taskFactory: TaskFactory

  @_spi(Internals)
  public init(
    method: HTTPMethod,
    options: HTTPRequestOptions? = nil,
    responseHandler: @escaping HTTPResponseHandler<Value>,
    taskFactory: TaskFactory
  ) {
    self.method = method
    self.options = options
    self.responseHandler = responseHandler
    self.taskFactory = taskFactory
  }
}

public typealias HTTPResponseHandler<Value> = (HTTPResponse) async throws -> Value
