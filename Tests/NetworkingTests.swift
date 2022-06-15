import Networking
import XCTest

@NetworkingActor
class NetworkingTests: XCTestCase {
  var gateway: HTTPGateway!
  var host: HTTPHost!

  @NetworkingActor
  override func setUp() {
    super.setUp()
    gateway = HTTPGateway()
    self.host = HTTPHost(
      baseURL: URL(string: "https://jsonplaceholder.typicode.com/posts")!,
      gateway: HTTPGateway()
    )
  }

  func testGateway() async throws {
    let request = HTTPRequest<Data>(
      method: .get,
      options: HTTPRequestOptions(urlPath: "1"),
      responseHandler: { response in response.data! },
      taskFactory: HTTPTaskFactory.dataTaskFactory()
    )

    let response = try await gateway.push(
      request: request,
      hostURL: URL(string: "https://jsonplaceholder.typicode.com/posts")!,
      hostOptions: nil,
      extraOptions: nil
    )
    let result = try JSONDecoder().decode(TestResponse.self, from: response.data!)
    print(result.title)
  }

  func testHost() async throws {
    host = HTTPHost(
      baseURL: URL(string: "https://jsonplaceholder.typicode.com/posts")!,
      gateway: HTTPGateway()
    )

    let request = HTTPRequest<TestResponse>(
      method: .get,
      options: HTTPRequestOptions(urlPath: "1"),
      responseHandler: { response in
        guard let data = response.data else {
          throw GatewayError.serverEmptyResponseData(url: nil)
        }
        return try JSONDecoder().decode(TestResponse.self, from: data)
      },
      taskFactory: HTTPTaskFactory.dataTaskFactory()
    )

    let response = try await host.push(request: request)
    print(response.title)
  }

  func testMergeOptions() async throws {
    host = HTTPHost(
      baseURL: URL(string: "https://jsonplaceholder.typicode.com/")!,
      gateway: HTTPGateway()
    )

    let request = HTTPRequestBuilder<TestResponse>(method: .get)
      .with(options: .init(urlPath: "posts"))
      .with(extraSuccessStatusCodes: [404])
      .build()

    let response = try await host.push(
      request: request,
      requestOptions: .init(urlPath: "1")
    )
    print(response.title)
  }

  func testDownloadTask() async throws {
    host = HTTPHost(
      baseURL: URL(
        string: """
          https://ru.depositphotos.com/112999024/stock-photo-view-of-mount-everest-and.html
          """
      )!,
      gateway: HTTPGateway()
    )

    let request = HTTPRequestBuilder<Void>(
      method: .get,
      taskFactory: HTTPTaskFactory.downloadTaskFactory { progress in
        print("Progress ready: \(progress.ready) total: \(progress.total)")
      } fileHandler: { url in
        print(url)
      }
    ).build()

    try await host.push(request: request)
    print("Success")
  }
}

struct TestResponse: Codable {
  let userId: Int
  let id: Int
  let title: String
  let body: String
}
