//
//  URLSession+Extension.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 25.08.2021.
//

import Foundation

extension URLSession {
  nonisolated(unsafe) private static let invalidateHandlerAssociation =
    ObjectAssociation<(Error?) -> Void>()

  var invalidateHandler: ((Error?) -> Void)? {
    get { Self.invalidateHandlerAssociation[self] }
    set { Self.invalidateHandlerAssociation[self] = newValue }
  }
}
