//
//  r+download.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 28.12.2022.
//

import Foundation

extension HTTPRequestBuilder where Value == URL {
  public enum DownloadError: Error {
    case moveFile(url: URL, reason: Error)
    case emptyFileURL
  }

  public struct FileMover {
    private let move: (URL) throws -> URL

    public init(_ move: @escaping (URL) throws -> URL) {
      self.move = move
    }

    public func callAsFunction(_ url: URL) throws -> URL {
      try move(url)
    }
  }

  public static func download(
    method: HTTPMethod = .get,
    downloadProgress: ((HTTPRequestProgress) -> Void)? = nil,
    moveFileToPermanentLocation: FileMover = .default
  ) -> Self {
    let downloadResult = LockIsolated<Result<URL, DownloadError>>(.failure(.emptyFileURL))
    return Self(
      method: method,
      taskFactory: HTTPTaskFactory.downloadTaskFactory(
        downloadProgress: downloadProgress,
        fileHandler: { fileURL in
          downloadResult.value = {
            do {
              return .success(try moveFileToPermanentLocation(fileURL))
            } catch {
              return .failure(.moveFile(url: fileURL, reason: error))
            }
          }()
        }
      ),
      dataHandler: { _ in
        switch downloadResult.value {
        case .success(let fileURL): return fileURL
        case .failure(let error): throw error
        }
      }
    )
  }
}

extension HTTPRequestBuilder.FileMover where Value == URL {
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
