//
//  HTTPRequestBuilder.swift
//  Networking
//
//  Created by Vasiliy Zaycev on 02.09.2021.
//

import Foundation

public final class HTTPRequestBuilder<Value> {
  private let method: HTTPMethod
  private let fileRemover: FileRemover
  private let taskFactory: TaskFactory
  private let dataHandler: HTTPDataHandler<Value>?
  private let optionalDataHandler: HTTPOptionalDataHandler<Value>?
  private var options: HTTPRequestOptions?
  private var customMetadataHandler: HTTPCustomMetadataHandler?
  private var customResponseHandler: HTTPCustomResponseHandler<Value>?
  private var extraSuccessStatusCodes: [Int] = []
  private var extraFailureStatusCodes: [Int] = []

  public convenience init(
    method: HTTPMethod,
    fileRemover: FileRemover = .default,
    taskFactory: TaskFactory = HTTPTaskFactory.dataTaskFactory(),
    keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy
  ) where Value: Decodable {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = keyDecodingStrategy
    self.init(method: method, taskFactory: taskFactory, decoder: decoder)
  }

  public convenience init(
    method: HTTPMethod,
    fileRemover: FileRemover = .default,
    taskFactory: TaskFactory = HTTPTaskFactory.dataTaskFactory(),
    decoder: ResponseDecoder = JSONDecoder()
  ) where Value: Decodable {
    self.init(method: method, taskFactory: taskFactory) { data in
      try decoder.decode(Value.self, from: data)
    }
  }

  public convenience init(
    method: HTTPMethod,
    fileRemover: FileRemover = .default,
    taskFactory: TaskFactory = HTTPTaskFactory.dataTaskFactory(),
    dataHandler: @escaping HTTPDataHandler<Value>
  ) {
    self.init(
      method: method,
      fileRemover: fileRemover,
      taskFactory: taskFactory,
      dataHandler: dataHandler,
      optionalDataHandler: nil
    )
  }

  public convenience init(
    method: HTTPMethod,
    fileRemover: FileRemover = .default,
    taskFactory: TaskFactory,
    optionalDataHandler: @escaping HTTPOptionalDataHandler<Value>
  ) {
    self.init(
      method: method,
      fileRemover: fileRemover,
      taskFactory: taskFactory,
      dataHandler: nil,
      optionalDataHandler: optionalDataHandler
    )
  }

  public convenience init(
    method: HTTPMethod,
    taskFactory: TaskFactory = HTTPTaskFactory.dataTaskFactory()
  ) where Value == Void {
    self.init(
      method: method,
      taskFactory: taskFactory,
      optionalDataHandler: { _ in () }
    )
  }

  private init(
    method: HTTPMethod,
    fileRemover: FileRemover,
    taskFactory: TaskFactory,
    dataHandler: HTTPDataHandler<Value>?,
    optionalDataHandler: HTTPOptionalDataHandler<Value>?
  ) {
    self.method = method
    self.fileRemover = fileRemover
    self.taskFactory = taskFactory
    self.dataHandler = dataHandler
    self.optionalDataHandler = optionalDataHandler
  }

  public func with(options: HTTPRequestOptions) -> Self {
    self.options = options
    return self
  }

  public func with(metadataHandler: HTTPCustomMetadataHandler?) -> Self {
    self.customMetadataHandler = metadataHandler
    return self
  }

  public func with(responseHandler: HTTPCustomResponseHandler<Value>?) -> Self {
    self.customResponseHandler = responseHandler
    return self
  }

  public func with(extraSuccessStatusCodes: [Int]) -> Self {
    self.extraSuccessStatusCodes = extraSuccessStatusCodes
    return self
  }

  public func with(extraFailureStatusCodes: [Int]) -> Self {
    self.extraFailureStatusCodes = extraFailureStatusCodes
    return self
  }

  public func build() -> HTTPRequest<Value> {
    .init(
      method: method,
      options: options,
      responseHandler: createResponseHandler(),
      taskFactory: taskFactory
    )
  }
}

public typealias HTTPMetadataHandler = @Sendable (HTTPURLResponse) throws -> Void
public typealias HTTPCustomMetadataHandler = @Sendable (
  HTTPMetadataHandler,
  HTTPURLResponse
) throws -> Void
public typealias HTTPMetadataHandlerWithCleanup = @Sendable (
  HTTPURLResponse,
  HTTPResponse.DownloadedFile?
) throws -> Void
public typealias HTTPDataHandler<Value> = @Sendable (Data) async throws -> Value
public typealias HTTPOptionalDataHandler<Value> = @Sendable (Data?) async throws -> Value
public typealias HTTPCustomResponseHandler<Value> = @Sendable (
  HTTPMetadataHandlerWithCleanup,
  FileRemover,
  HTTPResponseHandler<Value>,
  HTTPResponse
) async throws -> Value

private extension HTTPRequestBuilder {
  private func createResponseHandler() -> HTTPResponseHandler<Value> {
    let metadataHandlerWithCleanup = createMetadataHandlerWithCleanup()
    let dataHandler = createDataHandler()
    if let customResponseHandler {
      return { [fileRemover] response in
        try await customResponseHandler(
          metadataHandlerWithCleanup,
          fileRemover,
          dataHandler,
          response
        )
      }
    }
    return { response in
      try metadataHandlerWithCleanup(response.metadata, response.downloadedFile)
      return try await dataHandler(response)
    }
  }

  private func createMetadataHandlerWithCleanup() -> @Sendable (
    HTTPURLResponse,
    HTTPResponse.DownloadedFile?
  ) throws -> Void {
    { [metadataHandler = createMetadataHandler(), fileRemover] metadata, file in
      do {
        try metadataHandler(metadata)
      } catch {
        fileRemover.remove(file: file)
        throw error
      }
    }
  }

  private func createMetadataHandler() -> HTTPMetadataHandler {
    let extraSuccessStatusCodes = Set(extraSuccessStatusCodes)
    let extraFailureStatusCodes = Set(extraFailureStatusCodes)
    let metadataHandler: HTTPMetadataHandler = { metadata in
      if extraSuccessStatusCodes.contains(metadata.statusCode) {
        return
      }
      guard
        metadata.contains2XXStatusCode,
        !extraFailureStatusCodes.contains(metadata.statusCode)
      else {
        throw GatewayError.server(HTTPStatusCode: metadata.statusCode, url: metadata.url)
      }
    }
    guard let customMetadataHandler else { return metadataHandler }
    return { metadata in
      try customMetadataHandler(metadataHandler, metadata)
    }
  }

  private func createDataHandler() -> HTTPResponseHandler<Value> {
    let dataHandler = self.dataHandler
    let optionalDataHandler = self.optionalDataHandler
    return { response in
      if let optionalDataHandler {
        return try await optionalDataHandler(response.data)
      }
      if let dataHandler {
        guard let responseData = response.data else {
          throw GatewayError.serverEmptyResponseData(url: response.metadata.url)
        }
        return try await dataHandler(responseData)
      }
      fatalError("All dataHandlers is nil")
    }
  }
}
