//
//  File.swift
//  
//
//  Created by Василий Зайцев on 19.04.2024.
//

import Foundation

public struct FileMover: Sendable {
  private let move: @Sendable (URL) throws -> URL

  public init(_ move: @escaping @Sendable (URL) throws -> URL) {
    self.move = move
  }

  public func callAsFunction(_ url: URL) throws -> URL {
    try move(url)
  }
}

extension FileMover {
  public static let `default`: Self = .init { tempFileURL in
    let newURL = FileManager.default
      .documentsDirectoryURL
      .appendingPathComponent(UUID().uuidString)
    try FileManager.default.moveItem(at: tempFileURL, to: newURL)
    return newURL
  }
}

private extension FileManager {
  var documentsDirectoryURL: URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
  }
}
