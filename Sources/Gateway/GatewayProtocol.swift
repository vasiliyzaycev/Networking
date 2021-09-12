//
//  GatewayProtocol.swift
//  NetworkServiceDemo
//
//  Created by Vasily Zaytsev on 25.08.2021.
//

import Foundation

public protocol HTTPGatewayProtocol {
    var session: URLSession { get }

    @discardableResult
    func push(
        request: HTTPRequestProtocol,
        hostURL: URL,
        hostOptions: HTTPRequestOptions?,
        extraOptions: HTTPRequestOptions?,
        complitionHandler: @escaping (Result<HTTPResponse, Error>) -> Void
    ) -> CancelableTask

    func invalidate(forced: Bool, complitionHandler: ((Error?) -> Void)?)
}

public struct HTTPResponse {
    public let data: Data?
    public let metadata: HTTPURLResponse
}

public struct CancelableTask {
    let cancelClosure: () -> Void
}
