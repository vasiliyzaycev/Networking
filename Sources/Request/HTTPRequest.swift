//
//  Request.swift
//  NetworkService
//
//  Created by Vasiliy Zaytsev on 22.08.2021.
//

import Foundation

public struct HTTPRequest<Value>: Request {
  public let method: HTTPMethod
  public let options: HTTPRequestOptions?
  public let responseHandler: HTTPResponseHandler<Value>
  public let taskFactory: TaskFactory

  public init(
    method: HTTPMethod,
    options: HTTPRequestOptions? = nil,
    responseHandler: @escaping (HTTPResponse) throws -> Value,
    taskFactory: TaskFactory
  ) {
    self.method = method
    self.options = options
    self.responseHandler = responseHandler
    self.taskFactory = taskFactory
  }
}

public typealias HTTPResponseHandler<Value> = (HTTPResponse) throws -> Value
