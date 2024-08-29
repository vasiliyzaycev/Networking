//
//  HTTPMethod.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 31.08.2021.
//


public enum HTTPMethod: Equatable, Sendable {
  case get
  case put
  case post
  case delete
  case head
  case custom(String)

  var name: String {
    switch self {
    case .get:              "GET"
    case .put:              "PUT"
    case .post:             "POST"
    case .delete:           "DELETE"
    case .head:             "HEAD"
    case .custom(let name): name
    }
  }
}
