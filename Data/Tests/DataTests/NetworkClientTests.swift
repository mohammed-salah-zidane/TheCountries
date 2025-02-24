import XCTest
@testable import Data

class NetworkClientTests: XCTestCase {
    var sut: NetworkClient!
    var configuration: URLSessionConfiguration!
    
    override func setUp() {
        super.setUp()
        configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        sut = NetworkClient(configuration: configuration, logger: MockNetworkLogger())
    }
    
    override func tearDown() {
        sut = nil
        configuration = nil
        Task {
           await MockURLProtocol.clearResponseHandler()
        }
        super.tearDown()
    }
    
    func testSuccessfulRequest() async throws {
        // Given
        let mockCountry = CountryDTO(
            name: NameDTO(common: "Test", official: "Test", nativeName: nil),
            capital: ["TestCity"],
            currencies: nil,
            languages: nil,
            flags: FlagsDTO(png: "test.png", svg: "test.svg"),
            latlng: [0, 0],
            population: 100,
            area: 100,
            region: "Test"
        )
        let jsonData = try JSONEncoder().encode([mockCountry])
        
        await MockURLProtocol.setResponseHandler { request in
            return (HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!, jsonData)
        }
        
        // When
        let result: [CountryDTO] = try await sut.request(APIEndpoints.allCountries)
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name.common, "Test")
    }
    
    func testNoInternetConnection() async throws {
        // Given
        await MockURLProtocol.setResponseHandler { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://test.com")!,
                statusCode: 0,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        // When/Then
        do {
            let _: [CountryDTO] = try await sut.request(APIEndpoints.allCountries)
            XCTFail("Expected to throw an error")
        } catch {
            guard let networkError = error as? NetworkError else {
                XCTFail("Expected NetworkError, got \(error)")
                return
            }
            
            switch networkError {
            case .requestFailed(let statusCode, _):
                XCTAssertEqual(statusCode, 0)
            default:
                XCTFail("Expected requestFailed error, got \(networkError)")
            }
        }
    }
}
