//
//  Gateway.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 25.08.2021.
//

import Foundation

@NetworkingActor
public protocol Gateway {
  nonisolated var session: URLSession { get }

  @discardableResult
  func push(
    request: Request,
    hostURL: URL,
    hostOptions: HTTPOptions?,
    extraOptions: HTTPOptions?
  ) async throws -> HTTPResponse

  func invalidate(forced: Bool) async throws
}
