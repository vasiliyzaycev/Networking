//
//  URLSessionDelegateProxy.swift
//  Networking
//
//  Created by Vasiliy Zaytsev on 27.04.2022.
//

import Foundation

final class WeakProxy: NSObject {
  weak var object: NSObject?

  init(object: NSObject? = nil) {
    self.object = object
  }

  override func responds(to selector: Selector!) -> Bool {
    super.responds(to: selector) || object?.responds(to: selector) == true
  }

  override func forwardingTarget(for selector: Selector!) -> Any? {
    guard object?.responds(to: selector) == true else { return super.responds(to: selector) }
    return object
  }
}
