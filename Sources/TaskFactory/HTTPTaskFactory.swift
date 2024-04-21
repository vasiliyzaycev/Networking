//
//  TaskFactory.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 30.08.2021.
//

import Foundation

public struct HTTPTaskFactory: TaskFactory {
  public typealias Factory = @NetworkingActor @Sendable (
    URLRequest, Gateway
  ) throws -> URLSessionTask

  private let factory: Factory

  nonisolated public init(_ factory: @escaping Factory) {
    self.factory = factory
  }

  public func createTask(request: URLRequest, gateway: Gateway) throws -> URLSessionTask {
    try factory(request, gateway)
  }
}

extension HTTPTaskFactory {
  nonisolated public static func dataTaskFactory() -> TaskFactory {
    Self { (urlRequest: URLRequest, gateway: Gateway) in
      gateway.session.dataTask(with: urlRequest)
    }
  }

  nonisolated public static func downloadTaskFactory(
    downloadProgress: URLSessionDownloadTask.ProgressHandler? = nil,
    fileHandler: URLSessionDownloadTask.TempFileHandler?
  ) -> TaskFactory {
    Self { @NetworkingActor urlRequest, gateway in
      let task = gateway.session.downloadTask(with: urlRequest)
      task.downloadProgress = downloadProgress
      task.fileHandler = fileHandler
      return task
    }
  }
}
