//
//  HTTPResponse.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 28.04.2022.
//

import Foundation

public struct HTTPResponse: Sendable {
  public let data: Data?
  public let downloadedFile: URL?
  public let metadata: HTTPURLResponse
}
