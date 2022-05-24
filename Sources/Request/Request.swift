//
//  Request.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 01.09.2021.
//

import Foundation

public protocol Request {
  var method: HTTPMethod { get }
  var options: HTTPRequestOptions? { get }
  var taskFactory: TaskFactory { get }
}
