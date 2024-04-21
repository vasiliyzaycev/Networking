//
//  HTTPRequest+delete.swift
//  NetworkService
//
//  Created by Vasiliy Zaycev on 21.04.2024.
//

extension HTTPRequest {
  public static func delete(
    from urlPath: String
  ) -> HTTPRequest<Value> where Value: Decodable {
    .delete(options: .init(urlPath: urlPath))
  }

  public static func delete(
    from urlPath: String
  ) -> HTTPRequest<Void> {
    .delete(options: .init(urlPath: urlPath))
  }

  public static func delete(
    options: HTTPRequestOptions
  ) -> HTTPRequest<Value> where Value: Decodable {
    .build(method: .delete, options: options)
  }

  public static func delete(
    options: HTTPRequestOptions
  ) -> HTTPRequest<Void> {
    .build(method: .delete, options: options)
  }
}
