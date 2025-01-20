import XCTest
@testable import Core

final class CountryComponentsTests: XCTestCase {
    // MARK: - CountryName Tests
    
    func test_countryName_initialization() {
        // Given
        let common = "United States"
        let official = "United States of America"
        
        // When
        let countryName = CountryName(common: common, official: official)
        
        // Then
        XCTAssertEqual(countryName.common, common)
        XCTAssertEqual(countryName.official, official)
    }
    
    func test_countryName_equatable() {
        // Given
        let name1 = CountryName(common: "US", official: "USA")
        let name2 = CountryName(common: "US", official: "USA")
        let name3 = CountryName(common: "UK", official: "United Kingdom")
        
        // Then
        XCTAssertEqual(name1, name2)
        XCTAssertNotEqual(name1, name3)
    }
    
    // MARK: - Currency Tests
    
    func test_currency_initialization() {
        // Given
        let name = "US Dollar"
        let symbol = "$"
        
        // When
        let currency = Currency(name: name, symbol: symbol)
        
        // Then
        XCTAssertEqual(currency.name, name)
        XCTAssertEqual(currency.symbol, symbol)
    }
    
    func test_currency_formatted() {
        // Given
        let currency = Currency(name: "Euro", symbol: "€")
        
        // When
        let formatted = currency.formatted
        
        // Then
        XCTAssertEqual(formatted, "Euro (€)")
    }
    
    func test_currency_equatable() {
        // Given
        let currency1 = Currency(name: "USD", symbol: "$")
        let currency2 = Currency(name: "USD", symbol: "$")
        let currency3 = Currency(name: "EUR", symbol: "€")
        
        // Then
        XCTAssertEqual(currency1, currency2)
        XCTAssertNotEqual(currency1, currency3)
    }
    
    // MARK: - Coordinates Tests
    
    func test_coordinates_initialization() {
        // Given
        let latitude = 38.0
        let longitude = -97.0
        
        // When
        let coordinates = Coordinates(latitude: latitude, longitude: longitude)
        
        // Then
        XCTAssertEqual(coordinates.latitude, latitude)
        XCTAssertEqual(coordinates.longitude, longitude)
    }
    
    func test_coordinates_formatted() {
        // Given
        let coordinates = Coordinates(latitude: 51.5074, longitude: -0.1278)
        
        // When
        let formatted = coordinates.formatted
        
        // Then
        XCTAssertTrue(formatted.contains("51.51°"))
        XCTAssertTrue(formatted.contains("-0.13°"))
    }
    
    func test_coordinates_tuple() {
        // Given
        let latitude = 35.6762
        let longitude = 139.6503
        let coordinates = Coordinates(latitude: latitude, longitude: longitude)
        
        // When
        let tuple = coordinates.tuple
        
        // Then
        XCTAssertEqual(tuple.latitude, latitude)
        XCTAssertEqual(tuple.longitude, longitude)
    }
    
    func test_coordinates_equatable() {
        // Given
        let coords1 = Coordinates(latitude: 35.0, longitude: 135.0)
        let coords2 = Coordinates(latitude: 35.0, longitude: 135.0)
        let coords3 = Coordinates(latitude: 36.0, longitude: 136.0)
        
        // Then
        XCTAssertEqual(coords1, coords2)
        XCTAssertNotEqual(coords1, coords3)
    }
    
    func test_coordinates_formattedWithLocale() {
        // Given
        let coordinates = Coordinates(latitude: 12345.6789, longitude: -98765.4321)
        
        // When
        let formatted = coordinates.formatted
        
        // Then
        XCTAssertTrue(formatted.contains("12,345.68°"))
        XCTAssertTrue(formatted.contains("-98,765.43°"))
    }
}
