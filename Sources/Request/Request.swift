//
//  Request.swift
//  NetworkService
//
//  Created by Vasiliy Zaytsev on 22.08.2021.
//

import Foundation

public typealias HTTPResponseHandler<Value> = (HTTPResponse) throws -> Value

public struct HTTPRequest<Value>: HTTPRequestProtocol {
    public let method: HTTPMethod
    public let options: HTTPRequestOptions?
    public let responseHandler: HTTPResponseHandler<Value>
    public let taskFactory: HTTPTaskFactoryProtocol

    public init(
        method: HTTPMethod,
        options: HTTPRequestOptions? = nil,
        responseHandler: @escaping (HTTPResponse) throws -> Value,
        taskFactory: HTTPTaskFactoryProtocol
    ) {
        self.method = method
        self.options = options
        self.responseHandler = responseHandler
        self.taskFactory = taskFactory
    }
}
