//
//  HTTPRequestBuilder+download.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 28.12.2022.
//

import Foundation

extension HTTPRequestBuilder where Value == URL {
  public enum DownloadError: Error {
    case missingFileResult
  }

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
        fatalError("For this request dataHandler should not be called")
      }
    )
    return result.with { metadataHandlerWithCleanup, _, _, response in
      try metadataHandlerWithCleanup(response.metadata, response.downloadedFile)
      guard let fileResult = response.downloadedFile else {
        throw DownloadError.missingFileResult
      }
      return try fileResult.get()
    }
  }
}
