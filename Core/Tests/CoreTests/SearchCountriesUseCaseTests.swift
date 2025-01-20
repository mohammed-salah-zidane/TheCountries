import XCTest
@testable import Core

final class SearchCountriesUseCaseTests: XCTestCase {
    // MARK: - Properties
    
    private var sut: SearchCountriesUseCase!
    private var mockCountries: [Country]!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = SearchCountriesUseCase()
        mockCountries = [
            .mock(id: "US", name: CountryName(common: "United States", official: "United States of America"),
                  capital: "Washington", region: "Americas", population: 331002651, area: 9833517.0),
            .mock(id: "FR", name: CountryName(common: "France", official: "French Republic"),
                  capital: "Paris", region: "Europe", population: 67391582, area: 551695.0),
            .mock(id: "JP", name: CountryName(common: "Japan", official: "Japan"),
                  capital: "Tokyo", region: "Asia", population: 125836021, area: 377930.0)
        ]
    }
    
    override func tearDown() {
        sut = nil
        mockCountries = nil
        super.tearDown()
    }
    
    // MARK: - Search Tests
    
    func test_execute_withEmptyQuery_returnsAllCountries() {
        // Given
        let query = ""
        
        // When
        let result = sut.execute(query: query, in: mockCountries)
        
        // Then
        XCTAssertEqual(result, mockCountries)
    }
    
    func test_execute_withCommonNameQuery_returnsMatchingCountries() {
        // Given
        let query = "united"
        
        // When
        let result = sut.execute(query: query, in: mockCountries)
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "US")
    }
    
    func test_execute_withOfficialNameQuery_returnsMatchingCountries() {
        // Given
        let query = "Republic"
        
        // When
        let result = sut.execute(query: query, in: mockCountries)
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "FR")
    }
    
    func test_execute_withCapitalQuery_returnsMatchingCountries() {
        // Given
        let query = "Tokyo"
        
        // When
        let result = sut.execute(query: query, in: mockCountries)
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "JP")
    }
    
    func test_execute_withRegionQuery_returnsMatchingCountries() {
        // Given
        let query = "Asia"
        
        // When
        let result = sut.execute(query: query, in: mockCountries)
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "JP")
    }
    
    func test_execute_withNonMatchingQuery_returnsEmptyArray() {
        // Given
        let query = "XYZ123"
        
        // When
        let result = sut.execute(query: query, in: mockCountries)
        
        // Then
        XCTAssertTrue(result.isEmpty)
    }
    
    // MARK: - Sort Tests
    
    func test_sort_byName_sortsCountriesAlphabetically() {
        // When
        let result = sut.sort(mockCountries, by: .name)
        
        // Then
        XCTAssertEqual(result.map { $0.id }, ["FR", "JP", "US"])
    }
    
    func test_sort_byPopulation_sortsCountriesDescending() {
        // When
        let result = sut.sort(mockCountries, by: .population)
        
        // Then
        XCTAssertEqual(result.map { $0.id }, ["US", "JP", "FR"])
    }
    
    func test_sort_byArea_sortsCountriesDescending() {
        // When
        let result = sut.sort(mockCountries, by: .area)
        
        // Then
        XCTAssertEqual(result.map { $0.id }, ["US", "FR", "JP"])
    }
    
    func test_sort_byRegion_sortsCountriesAlphabetically() {
        // When
        let result = sut.sort(mockCountries, by: .region)
        
        // Then
        // Americas, Asia, Europe - this is the correct alphabetical order
        XCTAssertEqual(result.map { $0.id }, ["US", "JP", "FR"])
        // Verify the actual regions are in alphabetical order
        XCTAssertEqual(result.map { $0.region }, ["Americas", "Asia", "Europe"])
    }
}
// MARK: - Test Helpers

private extension Country {
    static func mock(
        id: String,
        name: CountryName,
        capital: String?,
        region: String,
        population: Int,
        area: Double?
    ) -> Country {
        Country(
            id: id,
            name: name,
            capital: capital,
            currency: nil,
            languages: [],
            flagUrl: nil,
            coordinates: nil,
            population: population,
            area: area,
            region: region
        )
    }
}
