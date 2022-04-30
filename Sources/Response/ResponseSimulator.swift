//
//  ResponseSimulator.swift
//  Networking
//
//  Created by Vasiliy Zaytsev on 29.04.2022.
//

import Foundation

public protocol ResponseSimulator {
  func probeSimulation(
    for request: Request,
    hostURL: URL,
    options: HTTPRequestOptions?
  ) -> HTTPResponse?
}
