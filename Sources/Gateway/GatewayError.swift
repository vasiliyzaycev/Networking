//
//  GatewayError.swift
//  Networking
//
//  Created by Vasiliy Zaytsev on 26.08.2021.
//

import Foundation

public enum GatewayError: Error {
  case network(reason: Error, url: URL)
  case server(HTTPStatusCode: Int, url: URL?)
  case serverEmptyResponseData(url: URL?)
  case systemEmptyResponse(url: URL)
}
