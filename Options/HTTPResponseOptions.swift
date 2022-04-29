//
//  HTTPResponseOptions.swift
//  Networking
//
//  Created by Vasiliy Zaytsev on 28.04.2022.
//

import Foundation

public struct HTTPSimulatedResponseOptions {
  public let rate: UInt
  public let simulator: HTTPResponseSimulator?
}

public protocol HTTPResponseSimulator {
  func probeSimulation(
    for request: Request,
    hostURL: URL,
    options: HTTPRequestOptions?
  ) -> HTTPResponse?
}
