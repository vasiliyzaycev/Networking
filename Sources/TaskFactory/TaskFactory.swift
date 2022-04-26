//
//  TaskFactory.swift
//  Networking
//
//  Created by Vasiliy Zaytsev on 31.08.2021.
//

import Foundation

public protocol TaskFactory {
  func task(request: URLRequest, gateway: Gateway) throws -> URLSessionTask
}
