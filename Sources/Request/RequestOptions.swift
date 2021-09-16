//
//  HTTPRequestOptions.swift
//  NetworkServiceDemo
//
//  Created by Vasiliy Zaytsev on 29.08.2021.
//

import Foundation

public struct HTTPRequestOptions {
    public let urlPath: String?
    public let urlQuery: [String: String]?
    public let headers: [String: String]?
    public let body: Data?
    public let responseTimeout: TimeInterval?
    public let allowUntrustedSSLCertificates: Bool?

    public init(
        urlPath: String? = nil,
        urlQuery: [String: String]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil,
        responseTimeout: TimeInterval? = nil,
        allowUntrustedSSLCertificates: Bool? = nil
    ) {
        self.urlPath = urlPath
        self.urlQuery = urlQuery
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

    public func merge(with options: HTTPRequestOptions?) -> HTTPRequestOptions {
        guard let options = options else { return self }
        return HTTPRequestOptions(
            urlPath: mergeURLPaths(with: options.urlPath),
            urlQuery: mergeURLQuery(with: options.urlQuery),
            headers: mergeHeaders(with: options.headers),
            body: options.body ?? body,
            responseTimeout: options.responseTimeout ?? responseTimeout,
            allowUntrustedSSLCertificates:
                options.allowUntrustedSSLCertificates ?? allowUntrustedSSLCertificates)
    }
}

private extension HTTPRequestOptions {
    private func mergeURLPaths(with targetURLPath: String?) -> String? {
        let slashCharacter = CharacterSet(charactersIn: "/")
        let sourceURLPath = urlPath?.trimmingCharacters(in: slashCharacter)
        guard
            let sourceURLPath = sourceURLPath,
            let targetURLPath = targetURLPath?.trimmingCharacters(in: slashCharacter)
        else {
            return sourceURLPath
        }
        return sourceURLPath + "/" + targetURLPath
    }

    private func mergeURLQuery(with targetURLQuery: [String: String]?) -> [String: String]? {
        return Dictionary.takeTargetMerging(source: urlQuery, target: targetURLQuery)
    }

    private func mergeHeaders(with targetHeaders: [String: String]?) -> [String: String]? {
        return Dictionary.takeTargetMerging(source: headers, target: targetHeaders)
    }
}
