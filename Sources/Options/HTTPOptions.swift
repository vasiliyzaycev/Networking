//
//  HTTPOptions.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 28.04.2022.
//

import Foundation

public struct HTTPOptions {
  public let requestOptions: HTTPRequestOptions?
  public let responseSimulator: ResponseSimulator?

  public init(
    requestOptions: HTTPRequestOptions? = nil,
    responseSimulator: ResponseSimulator? = nil
  ) {
    self.requestOptions = requestOptions
    self.responseSimulator = responseSimulator
  }

  public static func merge(
    _ source: HTTPOptions?,
    with target: HTTPOptions?
  ) -> HTTPOptions? {
    guard let source = source else { return target }
    return Self(
      requestOptions: .merge(source.requestOptions, with: target?.requestOptions),
      responseSimulator: target?.responseSimulator ?? source.responseSimulator
    )
  }

  public static func merge(
    _ source: HTTPOptions?,
    with target: HTTPRequestOptions?
  ) -> HTTPOptions? {
    merge(source, with: .init(requestOptions: target))
  }

  public static func merge(
    _ source: HTTPOptions?,
    with target: ResponseSimulator?
  ) -> HTTPOptions? {
    merge(source, with: .init(responseSimulator: target))
  }
}
