//
//  URLSessionDownloadTask+Extensions.swift
//  Networking
//
//  Created by Vasiliy Zaytsev on 25.08.2021.
//

import Foundation

extension URLSessionDownloadTask {
  private static var downloadCompletionHandlerKey: UInt8 = 0
  private static var downloadProgressKey: UInt8 = 0

  var downloadCompletionHandler: ((URL) -> Void)? {
    get { AssociatedObject.get(key: &Self.downloadCompletionHandlerKey, from: self) }
    set {
      AssociatedObject.set(value: newValue, key: &Self.downloadCompletionHandlerKey, to: self)
    }
  }

  var downloadProgress: ((HTTPRequestProgress) -> Void)? {
    get { AssociatedObject.get(key: &Self.downloadProgressKey, from: self) }
    set { AssociatedObject.set(value: newValue, key: &Self.downloadProgressKey, to: self) }
  }
}
