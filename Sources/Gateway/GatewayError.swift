//
//  GatewayError.swift
//  Networking
//
//  Created by Vasiliy Zaytsev on 26.08.2021.
//

import Foundation

public enum GatewayError: Error {
  case network(Error, URL)
  case serverEmptyResponseData(URL?)
  case serverWithHTTPStatusCode(Int, URL?)
  case systemEmptyResponse(URL)
}
