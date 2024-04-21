//
//  HTTPRequest+post.swift
//  NetworkService
//
//  Created by Vasiliy Zaycev on 21.04.2024.
//

extension HTTPRequest {
  public static func post(
    from urlPath: String
  ) -> HTTPRequest<Value> where Value: Decodable {
    .post(options: .init(urlPath: urlPath))
  }

  public static func post(
    from urlPath: String
  ) -> HTTPRequest<Void> {
    .post(options: .init(urlPath: urlPath))
  }

  public static func post(
    options: HTTPRequestOptions
  ) -> HTTPRequest<Value> where Value: Decodable {
    .build(method: .post, options: options)
  }

  public static func post(
    options: HTTPRequestOptions
  ) -> HTTPRequest<Void> {
    .build(method: .post, options: options)
  }
}
