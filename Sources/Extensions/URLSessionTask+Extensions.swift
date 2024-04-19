//
//  URLSessionTask+Extensions.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 25.08.2021.
//

import Foundation

extension URLSessionTask {
  nonisolated(unsafe) private static let allowUntrustedSSLAssociation =
    ObjectAssociation<NSNumber>() // swiftlint:disable:this legacy_objc_type
  nonisolated(unsafe) private static let completionHandlerAssociation =
    ObjectAssociation<(Error?) -> Void>()
  nonisolated(unsafe) private static let dataHandlerAssociation =
    ObjectAssociation<(Data) -> Void>()
  nonisolated(unsafe) private static let uploadProgressAssociation =
    ObjectAssociation<(HTTPRequestProgress) -> Void>()
  nonisolated(unsafe) private static let bodyStreamBuilderAssociation =
    ObjectAssociation<() -> InputStream>()

  public var allowUntrustedSSLCertificates: Bool {
    get { Self.allowUntrustedSSLAssociation[self]?.boolValue ?? false }
    // swiftlint:disable:next legacy_objc_type
    set { Self.allowUntrustedSSLAssociation[self] = NSNumber(value: newValue) }
  }

  public var completionHandler: ((Error?) -> Void)? {
    get { Self.completionHandlerAssociation[self] }
    set { Self.completionHandlerAssociation[self] = newValue }
  }

  public var dataHandler: ((Data) -> Void)? {
    get { Self.dataHandlerAssociation[self] }
    set { Self.dataHandlerAssociation[self] = newValue }
  }

  public var uploadProgress: ((HTTPRequestProgress) -> Void)? {
    get { Self.uploadProgressAssociation[self] }
    set { Self.uploadProgressAssociation[self] = newValue }
  }

  public var bodyStreamBuilder: (() -> InputStream)? {
    get { Self.bodyStreamBuilderAssociation[self] }
    set { Self.bodyStreamBuilderAssociation[self] = newValue }
  }
}
