//
//  HTTPRequest+common.swift
//  NetworkService
//
//  Created by Vasiliy Zaycev on 21.04.2024.
//

extension HTTPRequest {
  public static func build(
    method: HTTPMethod,
    options: HTTPRequestOptions
  ) -> HTTPRequest<Value> where Value: Decodable {
    HTTPRequestBuilder<Value>(method: method)
      .with(options: options)
      .build()
  }

  public static func build(
    method: HTTPMethod,
    options: HTTPRequestOptions
  ) -> HTTPRequest<Void> {
    HTTPRequestBuilder<Void>(method: method)
      .with(options: options)
      .build()
  }
}
