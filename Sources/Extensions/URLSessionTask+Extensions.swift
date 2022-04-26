//
//  URLSessionTask+Extensions.swift
//  Networking
//
//  Created by Vasiliy Zaytsev on 25.08.2021.
//

import Foundation

extension URLSessionTask {
  private static var allowUntrustedSSLCertificates: UInt8 = 0
  private static var completionHandlerKey: UInt8 = 0
  private static var dataHandlerKey: UInt8 = 0
  private static var uploadProgressKey: UInt8 = 0
  private static var bodyStreamBuilderKey: UInt8 = 0

  var allowUntrustedSSLCertificates: Bool {
    // swiftlint:disable legacy_objc_type
    get {
      let result = AssociatedObject<NSNumber>
        .get(key: &Self.allowUntrustedSSLCertificates, from: self)
      return result?.boolValue ?? false
    }
    set {
      AssociatedObject.set(
        value: NSNumber(value: newValue),
        key: &Self.allowUntrustedSSLCertificates,
        to: self
      )
    }
    // swiftlint:enable legacy_objc_type
  }

  var completionHandler: ((Error?) -> Void)? {
    get { AssociatedObject.get(key: &Self.completionHandlerKey, from: self) }
    set { AssociatedObject.set(value: newValue, key: &Self.completionHandlerKey, to: self) }
  }

  var dataHandler: ((Data) -> Void)? {
    get { AssociatedObject.get(key: &Self.dataHandlerKey, from: self) }
    set { AssociatedObject.set(value: newValue, key: &Self.dataHandlerKey, to: self) }
  }

  var uploadProgress: ((HTTPRequestProgress) -> Void)? {
    get { AssociatedObject.get(key: &Self.uploadProgressKey, from: self) }
    set { AssociatedObject.set(value: newValue, key: &Self.uploadProgressKey, to: self) }
  }

  var bodyStreamBuilder: (() -> InputStream)? {
    get { AssociatedObject.get(key: &Self.bodyStreamBuilderKey, from: self) }
    set { AssociatedObject.set(value: newValue, key: &Self.bodyStreamBuilderKey, to: self) }
  }
}
