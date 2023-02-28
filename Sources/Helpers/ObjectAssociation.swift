//
//  AssociatedObject.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 25.08.2021.
//

import Foundation

final class ObjectAssociation<T> {
  private let policy: objc_AssociationPolicy

  init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
    self.policy = policy
  }

  subscript(index: NSObject) -> T? {
    get {
      objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as? T
    }
    set {
      objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy)
    }
  }
}
