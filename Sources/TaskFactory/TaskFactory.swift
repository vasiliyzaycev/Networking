//
//  TaskFactory.swift
//  Networking
//
//  Created by Vasiliy Zaytsev on 31.08.2021.
//

import Foundation

public protocol TaskFactory {
  func createTask(request: URLRequest, gateway: Gateway) throws -> URLSessionTask
}
