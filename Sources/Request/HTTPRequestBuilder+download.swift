//
//  HTTPRequestBuilder+download.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 28.12.2022.
//

import Foundation

public enum HTTPDownloadError: Error {
  case defaultResponseHandlerNotRedefined
  case fileHandlerMissing
  case fileResultMissing
}

extension HTTPRequestBuilder where Value == URL {
  public static func download(
    method: HTTPMethod = .get,
    downloadProgress: URLSessionDownloadTask.ProgressHandler? = nil,
    moveFileToPermanentLocation: FileMover = .default
  ) -> Self {
    let result = Self(
      method: method,
      taskFactory: HTTPTaskFactory.downloadTaskFactory(
        downloadProgress: downloadProgress,
        fileHandler: moveFileToPermanentLocation.move
      ),
      dataHandler: { _ in
        throw HTTPDownloadError.defaultResponseHandlerNotRedefined
      }
    )
    return result.with { metadataHandlerWithCleanup, _, _, response in
      try metadataHandlerWithCleanup(response.metadata, response.downloadedFile)
      guard let fileResult = response.downloadedFile else {
        throw HTTPDownloadError.fileResultMissing
      }
      return try fileResult.get()
    }
  }
}
