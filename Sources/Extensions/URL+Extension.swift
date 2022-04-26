//
//  URL+Extension.swift
//  Networking
//
//  Created by Vasiliy Zaytsev on 30.08.2021.
//

import Foundation

extension URL {
  func urlByAppending(_ pathComponent: String?, query: [String: String]?) -> URL {
    var url = self
    let path = pathComponent?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
    if let path = path {
      assert(query == nil)
      url = appendingPathComponent(path)
    }
    guard
      let query = query,
      let separator = url.query != nil ? "&" : "?",
      let result = URL(string: url.absoluteString + separator + query.queryString)
    else {
      return url
    }
    assert(url.fragment == nil)
    return result
  }

  func urlByAppending(_ pathComponent: String?) -> URL {
    guard
      let pathComponent = pathComponent?
        .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
    else {
      return self
    }
    return appendingPathComponent(pathComponent)
  }
}
