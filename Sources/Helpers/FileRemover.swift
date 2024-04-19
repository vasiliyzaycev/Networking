//
//  File.swift
//  
//
//  Created by Василий Зайцев on 19.04.2024.
//

import Foundation

public struct FileRemover: Sendable {
  public let remove: @Sendable (URL?) -> Void

  public init(_ remove: @escaping @Sendable (URL?) -> Void) {
    self.remove = remove
  }
}

extension FileRemover {
  public static let `default`: Self = .init { fileURL in
    guard let fileURL else { return }
    try? FileManager.default.removeItem(at: fileURL)
  }
}
