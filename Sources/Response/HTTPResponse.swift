//
//  HTTPResponse.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 28.04.2022.
//

import Foundation

public struct HTTPResponse: Sendable {
  public typealias DownloadedFile = Result<URL, any Error>

  public let data: Data?
  public let downloadedFile: DownloadedFile?
  public let metadata: HTTPURLResponse

  public init(
    data: Data?,
    downloadedFile: DownloadedFile? = nil,
    metadata: HTTPURLResponse
  ) {
    self.data = data
    self.downloadedFile = downloadedFile
    self.metadata = metadata
  }
}
