//
//  HostProtocol.swift
//  NetworkService
//
//  Created by Vasily Zaytsev on 22.08.2021.
//

import Foundation

public protocol HTTPHostProtocol {
    @discardableResult
    func push<Value>(
        request: HTTPRequest<Value>,
        complitionHandler: @escaping (Result<Value, Error>) -> Void
    ) -> CancelableTask

    @discardableResult
    func push<Value>(
        request: HTTPRequest<Value>,
        options: HTTPRequestOptions?,
        complitionHandler: @escaping (Result<Value, Error>) -> Void
    ) -> CancelableTask
}
