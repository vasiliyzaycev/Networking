//
//  ResponseDecoder.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 31.08.2021.
//

import Foundation

public protocol ResponseDecoder: AnyObject {
  func decode<T: Decodable>(_ type: T.Type, from: Data) throws -> T
}

extension JSONDecoder: ResponseDecoder {}
