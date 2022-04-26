//
//  GatewayError.swift
//  Networking
//
//  Created by Vasiliy Zaytsev on 26.08.2021.
//

import Foundation

public enum GatewayError: Error {
  case network(URL?, String?)
  case server(String?)
  case serverWithHTTPStatusCode(Int)
}
