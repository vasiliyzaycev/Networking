//
//  RequestBuilder.swift
//  NetworkServiceDemo
//
//  Created by Vasily Zaytsev on 02.09.2021.
//

import Foundation

public typealias HTTPMetadataHandler = (HTTPURLResponse) throws -> Void
public typealias HTTPCustomMetadataHandler = (HTTPMetadataHandler, HTTPURLResponse) throws -> Void
public typealias HTTPDataHandler<Value> = (Data) throws -> Value
public typealias HTTPOptionalDataHandler<Value> = (Data?) throws -> Value
public typealias HTTPCustomResponseHandler<Value> =
    (HTTPResponseHandler<Value>, HTTPResponse) throws -> Value

public final class HTTPRequestBuilder<Value> {
    private let method: HTTPMethod
    private let taskFactory: HTTPTaskFactoryProtocol
    private let dataHandler: HTTPDataHandler<Value>?
    private let optionalDataHandler: HTTPOptionalDataHandler<Value>?
    private var options: HTTPRequestOptions?
    private var customMetadataHandler: HTTPCustomMetadataHandler?
    private var customResponseHandler: HTTPCustomResponseHandler<Value>?
    private var extraSuccessStatusCodes: [Int] = []
    private var extraFailureStatusCodes: [Int] = []

    convenience public init(
        method: HTTPMethod,
        taskFactory: HTTPTaskFactoryProtocol = HTTPTaskFactory.dataTaskFactory(),
        decoder: ResponseDecoderProtocol = JSONDecoder()
    ) where Value: Decodable {
        self.init(method: method, taskFactory: taskFactory) { data in
            try decoder.decode(Value.self, from: data)
        }
    }

    convenience public init(
        method: HTTPMethod,
        taskFactory: HTTPTaskFactoryProtocol,
        dataHandler: @escaping HTTPDataHandler<Value>
    ) {
        self.init(
            method: method,
            taskFactory: taskFactory,
            dataHandler: dataHandler,
            optionalDataHandler: nil)
    }

    convenience public init(
        method: HTTPMethod,
        taskFactory: HTTPTaskFactoryProtocol,
        optionalDataHandler: @escaping HTTPOptionalDataHandler<Value>
    ) {
        self.init(
            method: method,
            taskFactory: taskFactory,
            dataHandler: nil,
            optionalDataHandler: optionalDataHandler)
    }

    convenience public init(
        method: HTTPMethod,
        taskFactory: HTTPTaskFactoryProtocol
    ) where Value == Void {
        self.init(
            method: method,
            taskFactory: taskFactory,
            optionalDataHandler: { _ in () })
    }

    private init(
        method: HTTPMethod,
        taskFactory: HTTPTaskFactoryProtocol,
        dataHandler: HTTPDataHandler<Value>?,
        optionalDataHandler: HTTPOptionalDataHandler<Value>?
    ) {
        self.method = method
        self.taskFactory = taskFactory
        self.dataHandler = dataHandler
        self.optionalDataHandler = optionalDataHandler
    }

    public func with(options: HTTPRequestOptions) -> Self {
        self.options = options
        return self
    }

    public func with(metadataHandler: HTTPCustomMetadataHandler?) -> Self {
        self.customMetadataHandler = metadataHandler
        return self
    }

    public func with(responseHandler: HTTPCustomResponseHandler<Value>?) -> Self {
        self.customResponseHandler = responseHandler
        return self
    }

    public func with(extraSuccessStatusCodes: [Int]) -> Self {
        self.extraSuccessStatusCodes = extraSuccessStatusCodes
        return self
    }

    public func with(extraFailureStatusCodes: [Int]) -> Self {
        self.extraFailureStatusCodes = extraFailureStatusCodes
        return self
    }

    public func build() -> HTTPRequest<Value> {
        .init(
            method: method,
            options: options,
            responseHandler: createResponseHandler(),
            taskFactory: taskFactory)
    }
}

private extension HTTPRequestBuilder {
    private func createResponseHandler() -> HTTPResponseHandler<Value> {
        let metadataHandler = createMetadataHandler()
        let dataHandler = self.dataHandler
        let optionalDataHandler = self.optionalDataHandler
        let responseHandler: HTTPResponseHandler<Value> = { response in
            try metadataHandler(response.metadata)
            if let optionalDataHandler = optionalDataHandler {
                return try optionalDataHandler(response.data)
            } else if let dataHandler = dataHandler {
                guard let responseData = response.data else {
                    throw GatewayError.server("Еmpty response data")
                }
                return try dataHandler(responseData)
            }
            fatalError("All dataHandlers is nil")
        }
        guard let customResponseHandler = customResponseHandler else { return responseHandler }
        return { response in
            try customResponseHandler(responseHandler, response)
        }
    }

    private func createMetadataHandler() -> HTTPMetadataHandler {
        let extraSuccessStatusCodes = Set(extraSuccessStatusCodes)
        let extraFailureStatusCodes = Set(extraFailureStatusCodes)
        let metadataHandler: HTTPMetadataHandler = { metadata in
            if extraSuccessStatusCodes.contains(metadata.statusCode) {
                return
            }
            guard
                metadata.contains2XXStatusCode,
                !extraFailureStatusCodes.contains(metadata.statusCode)
            else {
                throw GatewayError.serverWithHTTPStatusCode(metadata.statusCode)
            }
        }
        guard let customMetadataHandler = customMetadataHandler else { return metadataHandler }
        return { metadata in
            try customMetadataHandler(metadataHandler, metadata)
        }
    }
}
