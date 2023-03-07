//
//  URLSessionDownloadTask+Extensions.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 25.08.2021.
//

import Foundation

extension URLSessionDownloadTask {
  private static let downloadCompletionHandlerAssociation = ObjectAssociation<(URL) -> Void>()
  private static let progressAssociation = ObjectAssociation<(HTTPRequestProgress) -> Void>()

  public var downloadCompletionHandler: ((URL) -> Void)? {
    get { Self.downloadCompletionHandlerAssociation[self] }
    set { Self.downloadCompletionHandlerAssociation[self] = newValue }
  }

  public var downloadProgress: ((HTTPRequestProgress) -> Void)? {
    get { Self.progressAssociation[self] }
    set { Self.progressAssociation[self] = newValue }
  }
}
