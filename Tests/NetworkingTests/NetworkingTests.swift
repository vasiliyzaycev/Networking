import Networking
import XCTest

class NetworkingTests: XCTestCase {
  let gateway = HTTPGateway()
  var host = HTTPHost(
    baseURL: URL(string: "https://jsonplaceholder.typicode.com/posts")!,
    gateway: HTTPGateway()
  )

  func testGateway() {
    let request = HTTPRequest<Data>(
      method: .get,
      options: HTTPRequestOptions(urlPath: "1"),
      responseHandler: { response in response.data! },
      taskFactory: HTTPTaskFactory.dataTaskFactory()
    )

    let expectation = XCTestExpectation()

    gateway.push(
      request: request,
      hostURL: URL(string: "https://jsonplaceholder.typicode.com/posts")!,
      hostOptions: nil,
      extraOptions: nil
    ) { result in
      switch result {
      case .success(let response):
        do {
          let response = try JSONDecoder().decode(TestResponse.self, from: response.data!)
          print(response.title)
          expectation.fulfill()
        } catch {
          print(":(")
        }
      case .failure(let error):
        print(error)
      }
    }

    wait(for: [expectation], timeout: 1)
  }

  func testHost() {
    host = HTTPHost(
      baseURL: URL(string: "https://jsonplaceholder.typicode.com/posts")!,
      gateway: HTTPGateway()
    )

    let request = HTTPRequest<TestResponse>(
      method: .get,
      options: HTTPRequestOptions(urlPath: "1"),
      responseHandler: { response in
        guard let data = response.data else {
          throw GatewayError.server("Еmpty response data")
        }
        return try JSONDecoder().decode(TestResponse.self, from: data)
      },
      taskFactory: HTTPTaskFactory.dataTaskFactory()
    )

    let expectation = XCTestExpectation()

    host.push(request: request) { result in
      switch result {
      case .success(let response):
        print(response.title)
        expectation.fulfill()
      case .failure(let error):
        print(error)
      }
    }

    wait(for: [expectation], timeout: 1)
  }

  func testMergeOptions() {
    host = HTTPHost(
      baseURL: URL(string: "https://jsonplaceholder.typicode.com/")!,
      gateway: HTTPGateway()
    )

    let request = HTTPRequestBuilder<TestResponse>(method: .get)
      .with(options: .init(urlPath: "posts"))
      .with(extraSuccessStatusCodes: [404])
      .build()

    let expectation = XCTestExpectation()

    host.push(
      request: request,
      options: HTTPRequestOptions(urlPath: "1")
    ) { result in
      switch result {
      case .success(let response):
        print(response.title)
        expectation.fulfill()
      case .failure(let error):
        print(error)
      }
    }

    wait(for: [expectation], timeout: 1)
  }

  func testDownloadTask() {
    host = HTTPHost(
      baseURL: URL(
        string: """
          https://images.pexels.com/photos/3599586/pexels-photo-3599586\
          .jpeg?cs=srgb&dl=pexels-valeriia-miller-3599586.jpg&fm=jpg
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

    let expectation = XCTestExpectation()

    host.push(request: request) { result in
      switch result {
      case .success:
        print("Success")
        expectation.fulfill()
      case .failure(let error):
        print(error)
      }
    }

    wait(for: [expectation], timeout: 2)
  }
}

struct TestResponse: Codable {
  let userId: Int
  let id: Int
  let title: String
  let body: String
}
