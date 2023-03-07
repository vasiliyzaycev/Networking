//
//  URLSessionTask+Extensions.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 25.08.2021.
//

import Foundation

extension URLSessionTask {
  // swiftlint:disable:next legacy_objc_type
  private static let allowUntrustedSSLAssociation = ObjectAssociation<NSNumber>()
  private static let completionHandlerAssociation = ObjectAssociation<(Error?) -> Void>()
  private static let dataHandlerAssociation = ObjectAssociation<(Data) -> Void>()
  private static let uploadProgressAssociation = ObjectAssociation<(HTTPRequestProgress) -> Void>()
  private static let bodyStreamBuilderAssociation = ObjectAssociation<() -> InputStream>()

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
