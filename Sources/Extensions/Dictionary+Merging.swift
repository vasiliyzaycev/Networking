//
//  Dictionary+Merging.swift
//  NetworkServiceDemo
//
//  Created by Vasiliy Zaytsev on 29.08.2021.
//

import Foundation

extension Dictionary {
    static func takeTargetMerging(
        source: [Key: Value]?,
        target: [Key: Value]?
    ) -> [Key: Value]? {
        guard let source = source else { return target }
        return source.takeNewMerging(new: target)
    }

    func takeNewMerging(new: [Key: Value]?) -> [Key: Value] {
        guard let new = new else { return self }
        return merging(new) { (_, new) in new }
    }
}
