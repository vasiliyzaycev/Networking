//
//  Dictionary+URLQueryConvertible.swift
//  NetworkServiceDemo
//
//  Created by Vasiliy Zaytsev on 29.08.2021.
//

import Foundation

protocol URLQueryConvertible {
    var queryItems: [URLQueryItem] { get }
    var queryString: String { get }
}

extension Dictionary: URLQueryConvertible {
    var queryItems: [URLQueryItem] {
        self.map { (key: Hashable, value: Value) in
            URLQueryItem(name: String(describing: key), value: String(describing: value))
        }
    }

    var queryString: String {
        queryItems.reduce([]) {
            guard let value = $1.value else { return $0 }
            return $0 + ["\($1.name)=\(value)"]
        }
        .joined(separator: "&")
    }
}

private extension String {
    var urlEncoded: String? {
        self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
