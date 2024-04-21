//
//  FileRemover.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 19.04.2024.
//

import Foundation

public struct FileRemover: Sendable {
  private let remove: @Sendable (URL) -> Void

  public init(_ remove: @escaping @Sendable (URL) -> Void) {
    self.remove = remove
  }

  public func remove(file: HTTPResponse.DownloadedFile?) {
    guard case let .success(fileUrl) = file else { return }
    remove(fileUrl)
  }
}

extension FileRemover {
  public static let `default`: Self = .init { fileURL in
    try? FileManager.default.removeItem(at: fileURL)
  }
}
