//
//  HTTPRequestOptions.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 29.08.2021.
//

import Foundation

public struct HTTPRequestOptions {
  public let urlPath: String?
  public let queryItems: [URLQueryItem]?
  public let headers: [String: String]?
  public let body: Data?
  public let responseTimeout: TimeInterval?
  public let allowUntrustedSSLCertificates: Bool?

  public init(
    urlPath: String? = nil,
    queryItems: [URLQueryItem]? = nil,
    headers: [String: String]? = nil,
    body: Data? = nil,
    responseTimeout: TimeInterval? = nil,
    allowUntrustedSSLCertificates: Bool? = nil
  ) {
    self.urlPath = urlPath
    self.queryItems = queryItems
    self.headers = headers
    self.body = body
    self.responseTimeout = responseTimeout
    self.allowUntrustedSSLCertificates = allowUntrustedSSLCertificates
  }

  public static func merge(
    _ source: HTTPRequestOptions?,
    with target: HTTPRequestOptions?
  ) -> HTTPRequestOptions? {
    guard let source = source else { return target }
    return source.merge(with: target)
  }
}

private extension HTTPRequestOptions {
  private func merge(with options: HTTPRequestOptions?) -> HTTPRequestOptions {
    guard let options = options else { return self }
    return HTTPRequestOptions(
      urlPath: mergeURLPaths(with: options.urlPath),
      queryItems: mergeQueryItems(with: options.queryItems),
      headers: mergeHeaders(with: options.headers),
      body: options.body ?? body,
      responseTimeout: options.responseTimeout ?? responseTimeout,
      allowUntrustedSSLCertificates:
        options.allowUntrustedSSLCertificates ?? allowUntrustedSSLCertificates
    )
  }

  private func mergeURLPaths(with targetURLPath: String?) -> String? {
    let slashCharacter = CharacterSet(charactersIn: "/")
    let sourceURLPath = urlPath?.trimmingCharacters(in: slashCharacter)
    let trimmedTargetURLPath = targetURLPath?.trimmingCharacters(in: slashCharacter)
    guard
      let sourceURLPath = sourceURLPath,
      let targetURLPath = trimmedTargetURLPath
    else {
      return sourceURLPath ?? trimmedTargetURLPath
    }
    return sourceURLPath + "/" + targetURLPath
  }

  private func mergeQueryItems(with targetQueryItems: [URLQueryItem]?) -> [URLQueryItem]? {
    guard let targetQueryItems = targetQueryItems else { return queryItems }
    guard let queryItems = queryItems else { return targetQueryItems }
    let targetNames = targetQueryItems.reduce(into: Set()) { result, item in
      result.insert(item.name)
    }
    return targetQueryItems + queryItems.filter { item in !targetNames.contains(item.name) }
  }

  private func mergeHeaders(with targetHeaders: [String: String]?) -> [String: String]? {
    Dictionary.takeTargetMerging(source: headers, target: targetHeaders)
  }
}
