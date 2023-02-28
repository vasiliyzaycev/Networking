//
//  TaskFactory.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 31.08.2021.
//

import Foundation

@NetworkingActor
public protocol TaskFactory {
  func createTask(request: URLRequest, gateway: Gateway) throws -> URLSessionTask
}
