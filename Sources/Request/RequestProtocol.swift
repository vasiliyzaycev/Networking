//
//  RequestProtocol.swift
//  NetworkServiceDemo
//
//  Created by Vasiliy Zaytsev on 01.09.2021.
//

import Foundation

public protocol HTTPRequestProtocol {
    var method: HTTPMethod { get }
    var options: HTTPRequestOptions? { get }
    var taskFactory: HTTPTaskFactoryProtocol { get }
}
