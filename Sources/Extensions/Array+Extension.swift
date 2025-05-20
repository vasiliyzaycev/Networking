//
//  Array+Extension.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 29.08.2021.
//

import Foundation

extension Array where Element == URLQueryItem {
  var queryString: String {
    self.compactMap { item in
      guard let name = item.name.urlEncoded else { return nil }
      let value = item.value?.urlEncoded ?? ""
      return "\(name)=\(value)"
    }
    .joined(separator: "&")
  }
}

private extension String {
  var urlEncoded: String? {
    var allowedCharacters = CharacterSet.urlQueryAllowed
    allowedCharacters.remove("+")
    allowedCharacters.remove("&")
    return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
  }
}
