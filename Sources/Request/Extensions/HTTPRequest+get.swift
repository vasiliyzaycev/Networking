//
//  HTTPRequest+get.swift
//  NetworkService
//
//  Created by Vasiliy Zaycev on 21.04.2024.
//

extension HTTPRequest {
  public static func get(
    from urlPath: String
  ) -> HTTPRequest<Value> where Value: Decodable {
    .get(options: .init(urlPath: urlPath))
  }

  public static func get(
    options: HTTPRequestOptions
  ) -> HTTPRequest<Value> where Value: Decodable {
    .build(method: .get, options: options)
  }
}
