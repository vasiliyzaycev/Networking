//
//  LockIsolated.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 26.02.2023.
//

import Foundation

final class LockIsolated<Value: Sendable>: @unchecked Sendable {
  private var _value: Value
  private let lock = NSRecursiveLock()

  var value: Value {
    get { lock.sync { self._value } }
    set { lock.sync { self._value = newValue } }
  }

  init(_ value: Value) {
    self._value = value
  }
}

extension NSRecursiveLock {
  @inlinable
  @discardableResult
  func sync<R>(work: () -> R) -> R {
    self.lock()
    defer { self.unlock() }
    return work()
  }
}
