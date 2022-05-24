//
//  Method.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 31.08.2021.
//

import Foundation

public enum HTTPMethod: Equatable {
  case get
  case put
  case post
  case delete
  case head
  case custom(String)

  var name: String {
    switch self {
    case .get: return "GET"
    case .put: return "PUT"
    case .post: return "POST"
    case .delete: return "DELETE"
    case .head: return "HEAD"
    case .custom(let name): return name
    }
  }
}
