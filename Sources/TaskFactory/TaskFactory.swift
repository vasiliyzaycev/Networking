//
//  TaskFactory.swift
//  NetworkServiceDemo
//
//  Created by Vasiliy Zaytsev on 30.08.2021.
//

import Foundation

public struct HTTPTaskFactory: HTTPTaskFactoryProtocol {
    private let factory: (URLRequest, HTTPGatewayProtocol) throws -> URLSessionTask

    public init(_ factory: @escaping (URLRequest, HTTPGatewayProtocol) throws -> URLSessionTask) {
        self.factory = factory
    }

    public func task(request: URLRequest, gateway: HTTPGatewayProtocol) throws -> URLSessionTask {
        try factory(request, gateway)
    }
}

extension HTTPTaskFactory {
    public static func dataTaskFactory() -> HTTPTaskFactoryProtocol {
        Self.init { (urlRequest: URLRequest, gateway: HTTPGatewayProtocol) in
            gateway.session.dataTask(with: urlRequest)
        }
    }

    public static func downloadTaskFactory(
        downloadProgress: ((HTTPRequestProgress) -> Void)? = nil,
        fileHandler: ((URL) -> Void)?
    ) -> HTTPTaskFactoryProtocol {
        Self.init { (urlRequest: URLRequest, gateway: HTTPGatewayProtocol) in
            let task = gateway.session.downloadTask(with: urlRequest)
            task.downloadProgress = downloadProgress
            task.downloadCompletionHandler = fileHandler
            return task
        }
    }
}

public struct HTTPRequestProgress {
    public let ready: UInt64
    public let total: UInt64
}
