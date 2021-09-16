//
//  TaskFactoryProtocol.swift
//  NetworkServiceDemo
//
//  Created by Vasiliy Zaytsev on 31.08.2021.
//

import Foundation

public protocol HTTPTaskFactoryProtocol {
    func task(
        request: URLRequest,
        gateway: HTTPGatewayProtocol
    ) throws -> URLSessionTask
}
