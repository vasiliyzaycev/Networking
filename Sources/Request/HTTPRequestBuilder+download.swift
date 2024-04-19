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

  public static func download(
    method: HTTPMethod = .get,
    downloadProgress: URLSessionDownloadTask.ProgressHandler? = nil,
    moveFileToPermanentLocation: FileMover = .default
  ) -> Self {
    let downloadResult = LockIsolated<Result<URL, DownloadError>>(.failure(.emptyFileURL))
    return Self(
      method: method,
      taskFactory: HTTPTaskFactory.downloadTaskFactory(
        downloadProgress: downloadProgress,
        fileHandler: { fileURL in
          do {
            let resultURL = try moveFileToPermanentLocation(fileURL)
            downloadResult.value = .success(resultURL)
            return resultURL
          } catch {
            downloadResult.value = .failure(.moveFile(url: fileURL, reason: error))
            throw error
          }
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
