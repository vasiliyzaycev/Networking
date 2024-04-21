//
//  HTTPRequest+put.swift
//  NetworkService
//
//  Created by Vasiliy Zaycev on 21.04.2024.
//

extension HTTPRequest {
  public static func put(
    from urlPath: String
  ) -> HTTPRequest<Value> where Value: Decodable {
    .put(options: .init(urlPath: urlPath))
  }

  public static func put(
    from urlPath: String
  ) -> HTTPRequest<Void> {
    .put(options: .init(urlPath: urlPath))
  }

  public static func put(
    options: HTTPRequestOptions
  ) -> HTTPRequest<Value> where Value: Decodable {
    .build(method: .put, options: options)
  }

  public static func put(
    options: HTTPRequestOptions
  ) -> HTTPRequest<Void> {
    .build(method: .put, options: options)
  }
}
