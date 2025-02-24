import XCTest
@testable import Data

// MARK: - Network Mocks
actor MockURLProtocolHandler {
    static let shared = MockURLProtocolHandler()
    private var responseHandler: (@Sendable (URLRequest) async throws -> (HTTPURLResponse, Data))?
    
    func setHandler(_ handler: @Sendable @escaping (URLRequest) async throws -> (HTTPURLResponse, Data)) {
        self.responseHandler = handler
    }
    
    func clearHandler() {
        self.responseHandler = nil
    }
    
    func handle(_ request: URLRequest) async throws -> (HTTPURLResponse, Data) {
        guard let handler = responseHandler else {
            throw URLError(.unknown)
        }
        return try await handler(request)
    }
}

@MainActor
class MockURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    private struct LoadingContext: @unchecked Sendable {
        weak var client: URLProtocolClient?
        weak var urlProtocol: MockURLProtocol?
    }
    
    override func startLoading() {
        let context = LoadingContext(client: client, urlProtocol: self)
        
        Task.detached {
            do {
                let (response, data) = try await MockURLProtocolHandler.shared.handle(context.urlProtocol?.request ?? URLRequest(url: URL(string: "about:blank")!))
                await MainActor.run {
                    guard let client = context.client, let urlProtocol = context.urlProtocol else { return }
                    client.urlProtocol(urlProtocol, didReceive: response, cacheStoragePolicy: .notAllowed)
                    client.urlProtocol(urlProtocol, didLoad: data)
                    client.urlProtocolDidFinishLoading(urlProtocol)
                }
            } catch {
                await MainActor.run {
                    guard let client = context.client, let urlProtocol = context.urlProtocol else { return }
                    client.urlProtocol(urlProtocol, didFailWithError: error)
                }
            }
        }
    }
    
    override func stopLoading() {}
    
    static func setResponseHandler(_ handler: @Sendable @escaping (URLRequest) async throws -> (HTTPURLResponse, Data)) async {
        await MockURLProtocolHandler.shared.setHandler(handler)
    }
    
    static func clearResponseHandler() async {
        await MockURLProtocolHandler.shared.clearHandler()
    }
}

class MockNetworkLogger: NetworkLoggerProtocol {
    required init() {}
    
    func logRequest(_ request: URLRequest) {}
    func logResponse(_ response: URLResponse?, data: Data?, error: Error?) {}
    func logError(_ error: Error) {}
}
