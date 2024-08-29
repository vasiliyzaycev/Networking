//
//  HTTPRequest.swift
//  NetworkService
//
//  Created by Vasiliy Zaycev on 22.08.2021.
//

public struct HTTPRequest<Value>: Request, Sendable {
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

public typealias HTTPResponseHandler<Value> = @Sendable (HTTPResponse) async throws -> Value
