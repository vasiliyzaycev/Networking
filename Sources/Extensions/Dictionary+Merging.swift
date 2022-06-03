//
//  Dictionary+Merging.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 29.08.2021.
//

import Foundation

extension Dictionary {
  static func takeTargetMerging(
    source: [Key: Value]?,
    target: [Key: Value]?
  ) -> [Key: Value]? {
    guard let source = source else { return target }
    return source.takeTargetMerging(target: target)
  }

  func takeTargetMerging(target: [Key: Value]?) -> [Key: Value] {
    guard let target = target else { return self }
    return merging(target) { _, target in target }
  }
}
