import XCTest
@testable import Data
import Core

class CountryRepositoryTests: XCTestCase {
    var sut: CountryRepository!
    var mockRemote: MockRemoteDataSource!
    var mockLocal: MockLocalDataSource!
    
    override func setUp() {
        super.setUp()
        mockRemote = MockRemoteDataSource()
        mockLocal = MockLocalDataSource()
        sut = CountryRepository(remoteDataSource: mockRemote, localDataSource: mockLocal)
    }
    
    override func tearDown() {
        sut = nil
        mockRemote = nil
        mockLocal = nil
        super.tearDown()
    }
    
    func testFetchAllCountriesSuccess() async throws {
        // Given
        let mockCountry = CountryDTO(
            name: NameDTO(common: "Test", official: "Test", nativeName: nil),
            capital: ["TestCity"],
            currencies: ["USD": CurrencyDTO(name: "US Dollar", symbol: "$")],
            languages: ["eng": "English"],
            flags: FlagsDTO(png: "test.png", svg: "test.svg"),
            latlng: [0, 0],
            population: 100,
            area: 100,
            region: "Test"
        )
        mockRemote.mockResult = .success([mockCountry])
        
        // When
        let countries = try await sut.fetchAllCountries()
        
        // Then
        XCTAssertEqual(countries.count, 1)
        XCTAssertEqual(countries.first?.name.common, "Test")
        XCTAssertEqual(mockLocal.savedItems.count, 1)
    }
    
    func testFetchAllCountriesFallbackToLocal() async throws {
        // Given
        mockRemote.mockResult = .failure(NetworkError.noInternetConnection)
        let mockCountry = CountryDTO(
            name: NameDTO(common: "Local", official: "Local", nativeName: nil),
            capital: ["LocalCity"],
            currencies: nil,
            languages: nil,
            flags: FlagsDTO(png: "local.png", svg: "local.svg"),
            latlng: [0, 0],
            population: 100,
            area: 100,
            region: "Local"
        )
        mockLocal.mockResult = .success([mockCountry])
        
        // When
        let countries = try await sut.fetchAllCountries()
        
        // Then
        XCTAssertEqual(countries.count, 1)
        XCTAssertEqual(countries.first?.name.common, "Local")
    }
}
