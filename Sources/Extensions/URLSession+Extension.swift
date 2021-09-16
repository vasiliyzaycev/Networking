//
//  URLSession+Extension.swift
//  NetworkServiceDemo
//
//  Created by Vasiliy Zaytsev on 25.08.2021.
//

import Foundation

extension URLSession {
    private static var urlSessionInvalidateHandler: UInt8 = 0

    var invalidateHandler: ((Error?) -> Void)? {
        get {
            AssociatedObject.get(key: &Self.urlSessionInvalidateHandler, from: self)
        }
        set {
            AssociatedObject.set(value: newValue, key: &Self.urlSessionInvalidateHandler, to: self)
        }
    }
}
