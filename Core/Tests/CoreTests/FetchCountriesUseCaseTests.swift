import XCTest
@testable import Core

final class FetchCountriesUseCaseTests: XCTestCase {
    // MARK: - Properties
    
    private var sut: FetchCountriesUseCase!
    private var mockRepository: MockCountryRepository!
    private var mockCachePolicy: MockCachePolicy!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockRepository = MockCountryRepository()
        mockCachePolicy = MockCachePolicy()
        sut = FetchCountriesUseCase(
            repository: mockRepository,
            cachePolicy: mockCachePolicy
        )
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockCachePolicy = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func test_execute_withValidLocalData_usesLocalWithRemoteRefreshPolicy() async throws {
        // Given
        mockRepository.hasValidLocalDataResult = true
        let expectedCountries = [Country.mock()]
        mockRepository.fetchAllCountriesResult = expectedCountries
        
        // When
        let result = try await sut.execute()
        
        // Then
        XCTAssertEqual(result, expectedCountries)
        XCTAssertEqual(mockRepository.lastUsedPolicy, .localWithRemoteRefresh)
    }
    
    func test_execute_withoutValidLocalData_usesRemoteWithLocalFallbackPolicy() async throws {
        // Given
        mockRepository.hasValidLocalDataResult = false
        let expectedCountries = [Country.mock()]
        mockRepository.fetchAllCountriesResult = expectedCountries
        
        // When
        let result = try await sut.execute()
        
        // Then
        XCTAssertEqual(result, expectedCountries)
        XCTAssertEqual(mockRepository.lastUsedPolicy, .remoteWithLocalFallback)
    }
    
    func test_execute_withExplicitPolicy_usesProvidedPolicy() async throws {
        // Given
        let expectedCountries = [Country.mock()]
        mockRepository.fetchAllCountriesResult = expectedCountries
        let explicitPolicy: DataSourcePolicy = .remoteOnly
        
        // When
        let result = try await sut.execute(policy: explicitPolicy)
        
        // Then
        XCTAssertEqual(result, expectedCountries)
        XCTAssertEqual(mockRepository.lastUsedPolicy, explicitPolicy)
    }
    
    func test_execute_withRepositoryError_throwsTransformedError() async {
        // Given
        struct TestError: Error {}
        mockRepository.fetchAllCountriesError = TestError()
        
        // When/Then
        do {
            _ = try await sut.execute()
            XCTFail("Expected error to be thrown")
        } catch let error as CoreError {
            XCTAssertEqual(error, .repositoryError(TestError().localizedDescription))
        } catch {
            XCTFail("Expected CoreError")
        }
    }
    
    func test_execute_withCoreError_propagatesOriginalError() async {
        // Given
        let expectedError = CoreError.invalidData
        mockRepository.fetchAllCountriesError = expectedError
        
        // When/Then
        do {
            _ = try await sut.execute()
            XCTFail("Expected error to be thrown")
        } catch let error as CoreError {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Expected CoreError")
        }
    }
}

// MARK: - Mock Objects

private final class MockCountryRepository: CountryRepositoryProtocol {
    var fetchAllCountriesResult: [Country] = []
    var fetchAllCountriesError: Error?
    var hasValidLocalDataResult = false
    var lastUsedPolicy: DataSourcePolicy?
    
    func fetchAllCountries(policy: DataSourcePolicy) async throws -> [Country] {
        lastUsedPolicy = policy
        if let error = fetchAllCountriesError {
            throw error
        }
        return fetchAllCountriesResult
    }
    
    func updateLocalStorage(with countries: [Country]) async throws {
        // No-op for tests
    }
    
    func clearLocalStorage() async throws {
        // No-op for tests
    }
    
    func hasValidLocalData() async -> Bool {
        return hasValidLocalDataResult
    }
}

private final class MockCachePolicy: CachePolicyProtocol {
    // MARK: - Properties
    
    let expirationTime: TimeInterval = 3600
    var isValidResult: Bool = true
    
    // MARK: - CachePolicyProtocol
    
    func isValid(lastUpdateTime: Date) -> Bool {
        return isValidResult
    }
}

// MARK: - Test Helpers

private extension Country {
    static func mock() -> Country {
        Country(
            id: "US",
            name: CountryName(common: "United States", official: "United States of America"),
            capital: "Washington",
            currency: nil,
            languages: ["eng"],
            flagUrl: nil,
            coordinates: nil,
            population: 331002651,
            area: 9833517.0,
            region: "Americas"
        )
    }
}
