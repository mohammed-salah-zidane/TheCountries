import XCTest
@testable import Data
import Core

class CountryMapperTests: XCTestCase {
    func testMapToDomainWithFullData() throws {
        // Given
        let dto = CountryDTO(
            name: NameDTO(common: "Test", official: "Test Official", nativeName: nil),
            capital: ["Test Capital"],
            currencies: ["USD": CurrencyDTO(name: "US Dollar", symbol: "$")],
            languages: ["eng": "English"],
            flags: FlagsDTO(png: "https://test.png", svg: "https://test.svg"),
            latlng: [10.0, 20.0],
            population: 1000,
            area: 100.0,
            region: "Test Region"
        )
        
        // When
        let domain = CountryMapper.mapToDomain(dto)
        
        // Then
        XCTAssertEqual(domain.name.common, "Test")
        XCTAssertEqual(domain.name.official, "Test Official")
        XCTAssertEqual(domain.capital, "Test Capital")
        XCTAssertEqual(domain.currency?.name, "US Dollar")
        XCTAssertEqual(domain.currency?.symbol, "$")
        XCTAssertEqual(domain.languages, ["English"])
        XCTAssertEqual(domain.flagUrl?.absoluteString, "https://test.png")
        XCTAssertEqual(domain.coordinates?.latitude, 10.0)
        XCTAssertEqual(domain.coordinates?.longitude, 20.0)
        XCTAssertEqual(domain.population, 1000)
        XCTAssertEqual(domain.area, 100.0)
        XCTAssertEqual(domain.region, "Test Region")
    }
    
    func testMapToDomainWithMinimalData() throws {
        // Given
        let dto = CountryDTO(
            name: NameDTO(common: "Test", official: "Test", nativeName: nil),
            capital: nil,
            currencies: nil,
            languages: nil,
            flags: FlagsDTO(png: "test.png", svg: "test.svg"),
            latlng: nil,
            population: 100,
            area: nil,
            region: "Test"
        )
        
        // When
        let domain = CountryMapper.mapToDomain(dto)
        
        // Then
        XCTAssertEqual(domain.name.common, "Test")
        XCTAssertNil(domain.capital)
        XCTAssertNil(domain.currency)
        XCTAssertTrue(domain.languages.isEmpty)
        XCTAssertNil(domain.coordinates)
        XCTAssertNil(domain.area)
    }
}
