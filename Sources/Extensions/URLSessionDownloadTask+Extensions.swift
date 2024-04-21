//
//  URLSessionDownloadTask+Extensions.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 25.08.2021.
//

import Foundation

extension URLSessionDownloadTask {
  public typealias ProgressHandler = @Sendable (HTTPRequestProgress) -> Void
  public typealias TempFileHandler = @Sendable (URL) throws -> URL

  nonisolated(unsafe) private static let downloadedFileAssociation =
    ObjectAssociation<HTTPResponse.DownloadedFile>()
  nonisolated(unsafe) private static let fileHandlerAssociation =
    ObjectAssociation<TempFileHandler>()
  nonisolated(unsafe) private static let progressAssociation =
    ObjectAssociation<ProgressHandler>()

  public var downloadedFile: HTTPResponse.DownloadedFile? {
    get { Self.downloadedFileAssociation[self] }
    set { Self.downloadedFileAssociation[self] = newValue }
  }

  public var downloadProgress: ProgressHandler? {
    get { Self.progressAssociation[self] }
    set { Self.progressAssociation[self] = newValue }
  }

  public var fileHandler: TempFileHandler? {
    get { Self.fileHandlerAssociation[self] }
    set { Self.fileHandlerAssociation[self] = newValue }
  }
}
