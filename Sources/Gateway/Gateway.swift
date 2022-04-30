//
//  Gateway.swift
//  Networking
//
//  Created by Vasiliy Zaytsev on 25.08.2021.
//

import Foundation

public protocol Gateway {
  var session: URLSession { get }

  @discardableResult
  func push(
    request: Request,
    hostURL: URL,
    hostOptions: HTTPOptions?,
    extraOptions: HTTPOptions?,
    completionHandler: @escaping (Result<HTTPResponse, Error>) -> Void
  ) -> CancelableTask

  func invalidate(forced: Bool, completionHandler: ((Error?) -> Void)?)
}

public struct CancelableTask {
  let cancelClosure: () -> Void
}
