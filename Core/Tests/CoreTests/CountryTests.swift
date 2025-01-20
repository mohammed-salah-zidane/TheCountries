import XCTest
@testable import Core

final class CountryTests: XCTestCase {
    // MARK: - Properties
    
    private var sut: Country!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = Country(
            id: "US",
            name: CountryName(common: "United States", official: "United States of America"),
            capital: "Washington",
            currency: Currency(name: "US Dollar", symbol: "$"),
            languages: ["eng"],
            flagUrl: URL(string: "https://example.com/flag.png"),
            coordinates: Coordinates(latitude: 38.0, longitude: -97.0),
            population: 331002651,
            area: 9833517.0,
            region: "Americas"
        )
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Formatting Tests
    
    func test_formattedPopulation_returnsFormattedString() {
        // When
        let result = sut.formattedPopulation
        
        // Then
        XCTAssertEqual(result, "331,002,651")
    }
    
    func test_formattedArea_withValue_returnsFormattedString() {
        // When
        let result = sut.formattedArea
        
        // Then
        XCTAssertEqual(result, "9,833,517 km²")
    }
    
    func test_formattedArea_withNilValue_returnsNil() {
        // Given
        sut = Country(
            id: "TEST",
            name: CountryName(common: "Test", official: "Test"),
            capital: nil,
            currency: nil,
            languages: [],
            flagUrl: nil,
            coordinates: nil,
            population: 0,
            area: nil,
            region: "Test"
        )
        
        // When
        let result = sut.formattedArea
        
        // Then
        XCTAssertNil(result)
    }
    
    // MARK: - Search Tests
    
    func test_matches_withCommonNameMatch_returnsTrue() {
        // When
        let result = sut.matches(query: "United")
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_matches_withOfficialNameMatch_returnsTrue() {
        // When
        let result = sut.matches(query: "America")
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_matches_withCapitalMatch_returnsTrue() {
        // When
        let result = sut.matches(query: "Washington")
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_matches_withRegionMatch_returnsTrue() {
        // When
        let result = sut.matches(query: "Americas")
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_matches_withNonMatch_returnsFalse() {
        // When
        let result = sut.matches(query: "XYZ123")
        
        // Then
        XCTAssertFalse(result)
    }
    
    func test_matches_isCaseInsensitive() {
        // When
        let result = sut.matches(query: "united states")
        
        // Then
        XCTAssertTrue(result)
    }
}
