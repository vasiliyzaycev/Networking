//
//  HTTPOptions.swift
//  Networking
//
//  Created by Vasiliy Zaytsev on 28.04.2022.
//

import Foundation

public struct HTTPOptions {
  public let requestOptions: HTTPRequestOptions?
  public let simulatedResponseOptions: HTTPSimulatedResponseOptions?

  public init(
    requestOptions: HTTPRequestOptions? = nil,
    simulatedResponseOptions: HTTPSimulatedResponseOptions? = nil
  ) {
    self.requestOptions = requestOptions
    self.simulatedResponseOptions = simulatedResponseOptions
  }

  public static func merge(
    _ source: HTTPOptions?,
    with target: HTTPOptions?
  ) -> HTTPOptions? {
    guard let source = source else { return target }
    return HTTPOptions(
      requestOptions: HTTPRequestOptions.merge(source.requestOptions, with: target?.requestOptions),
      simulatedResponseOptions: target?.simulatedResponseOptions ?? source.simulatedResponseOptions
    )
  }

  public static func merge(
    _ source: HTTPOptions?,
    with target: HTTPRequestOptions?
  ) -> HTTPOptions? {
    merge(source, with: HTTPOptions(requestOptions: target))
  }

  public static func merge(
    _ source: HTTPOptions?,
    with target: HTTPSimulatedResponseOptions?
  ) -> HTTPOptions? {
    merge(source, with: HTTPOptions(simulatedResponseOptions: target))
  }
}
