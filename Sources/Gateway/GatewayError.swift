//
//  GatewayError.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 26.08.2021.
//

import Foundation

public enum GatewayError: Error {
  case cancel(reason: Error, url: URL)
  case invalidGateway
  case noNetwork(reason: Error, url: URL)
  case network(reason: Error, url: URL)
  case server(HTTPStatusCode: Int, url: URL?)
  case serverEmptyResponseData(url: URL?)
  case systemEmptyResponse(url: URL)
  case systemNotEnoughDiskSpace(url: URL)
}

public extension GatewayError {
  static func createGatewayError(_ error: Error, url: URL) -> GatewayError {
    switch error {
    case let error as URLError where error.isNoNetwork:
      return .noNetwork(reason: error, url: url)

    case let error as NSError where error.isCancelled:
      return .cancel(reason: error, url: url)

    case let error as NSError where error.isNotEnoughDiskSpace:
      return .systemNotEnoughDiskSpace(url: url)

    default:
      return .network(reason: error, url: url)
    }
  }
}

private extension URLError {
  var isNoNetwork: Bool { code == .notConnectedToInternet }
}

private extension NSError {
  var isCancelled: Bool { domain == NSURLErrorDomain && code == NSURLErrorCancelled }
  var isNotEnoughDiskSpace: Bool { isPosixENOSPC || isCocoaOutOfSpace }

  private var isPosixENOSPC: Bool {
    domain == NSPOSIXErrorDomain && code == ENOSPC
  }
  private var isCocoaOutOfSpace: Bool {
    domain == NSCocoaErrorDomain && code == NSFileWriteOutOfSpaceError
  }
}
