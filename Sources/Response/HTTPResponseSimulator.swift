//
//  HTTPResponseSimulator.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 29.04.2022.
//

import Foundation

public struct HTTPResponseSimulator: ResponseSimulator {
  public typealias Simulator = @Sendable (Request, URL, HTTPRequestOptions?) -> HTTPResponse?

  /// Value in [0..100] range which specifies probability percent of the failure simulation.
  /// - Value 0 means that simulation is off.
  /// - Value 100 or more means that all responses will be simulated.
  private let rate: UInt
  private let simulator: Simulator

  public init(rate: UInt, _ simulator: @escaping Simulator) {
    self.rate = rate
    self.simulator = simulator
  }

  public func probeSimulation(
    for request: Request,
    hostURL: URL,
    options: HTTPRequestOptions?
  ) -> HTTPResponse? {
    guard Int.random(in: 0...100) <= rate else { return nil }
    return simulator(request, hostURL, options)
  }
}

public extension HTTPOptions {
  init(
    requestOptions: HTTPRequestOptions? = nil,
    rate: UInt,
    simulatorClosure: @escaping HTTPResponseSimulator.Simulator
  ) {
    self.init(
      requestOptions: requestOptions,
      responseSimulator: HTTPResponseSimulator(rate: rate, simulatorClosure)
    )
  }
}
