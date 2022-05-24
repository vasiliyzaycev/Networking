//
//  TaskFactory.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 30.08.2021.
//

import Foundation

public struct HTTPTaskFactory: TaskFactory {
  private let factory: (URLRequest, Gateway) throws -> URLSessionTask

  public init(_ factory: @escaping (URLRequest, Gateway) throws -> URLSessionTask) {
    self.factory = factory
  }

  public func createTask(request: URLRequest, gateway: Gateway) throws -> URLSessionTask {
    try factory(request, gateway)
  }
}

extension HTTPTaskFactory {
  public static func dataTaskFactory() -> TaskFactory {
    Self { (urlRequest: URLRequest, gateway: Gateway) in
      gateway.session.dataTask(with: urlRequest)
    }
  }

  public static func downloadTaskFactory(
    downloadProgress: ((HTTPRequestProgress) -> Void)? = nil,
    fileHandler: ((URL) -> Void)?
  ) -> TaskFactory {
    Self { (urlRequest: URLRequest, gateway: Gateway) in
      let task = gateway.session.downloadTask(with: urlRequest)
      task.downloadProgress = downloadProgress
      task.downloadCompletionHandler = fileHandler
      return task
    }
  }
}
