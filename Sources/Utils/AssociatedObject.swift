//
//  AssociatedObject.swift
//  NetworkServiceDemo
//
//  Created by Vasiliy Zaytsev on 25.08.2021.
//

import Foundation

enum AssociatedObject<T> {
    static func get(key: UnsafeRawPointer, from object: NSObject) -> T? {
        objc_getAssociatedObject(object, key) as? T
    }

    static func set(value: T?, key: UnsafeRawPointer, to object: NSObject) {
        let policy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        objc_setAssociatedObject(object, key, value, policy)
    }
}
