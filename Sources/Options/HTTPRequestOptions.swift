//
//  HTTPRequestOptions.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 29.08.2021.
//

import Foundation

public struct HTTPRequestOptions: Sendable {
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

  public init(
    urlPath: String? = nil,
    headers: [String: String]? = nil,
    bodyItems: [URLQueryItem],
    responseTimeout: TimeInterval? = nil,
    allowUntrustedSSLCertificates: Bool? = nil
  ) {
    self.init(
      urlPath: urlPath,
      headers: headers,
      body: Data(bodyItems.queryString.utf8),
      responseTimeout: responseTimeout,
      allowUntrustedSSLCertificates: allowUntrustedSSLCertificates
    )
  }

  public static func merge(_ source: Self?, with target: Self?) -> Self? {
    guard let source = source else { return target }
    return source.merge(with: target)
  }
}

private extension HTTPRequestOptions {
  private func merge(with options: Self?) -> Self {
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
    guard
      let sourceURLPath = urlPath,
      let targetURLPath = targetURLPath
    else {
      return urlPath ?? targetURLPath
    }
    let separator = sourceURLPath.hasSuffix("/") ? "" : "/"
    return sourceURLPath + separator + targetURLPath
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
