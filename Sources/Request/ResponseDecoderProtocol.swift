//
//  ResponseDecoderProtocol.swift
//  NetworkServiceDemo
//
//  Created by Vasily Zaytsev on 31.08.2021.
//

import Foundation

public protocol ResponseDecoderProtocol: AnyObject {
    func decode<T: Decodable>(_ type: T.Type, from: Data) throws -> T
}

extension JSONDecoder: ResponseDecoderProtocol {}
