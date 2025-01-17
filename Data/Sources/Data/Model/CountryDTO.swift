import Foundation

// Make DTOs public
public struct CountryDTO: Codable {
    public let name: NameDTO
    public let capital: [String]?
    public let currencies: [String: CurrencyDTO]?
    public let languages: [String: String]?
    public let flags: FlagsDTO
    public let latlng: [Double]?
    public let population: Int
    public let area: Double?
    public let region: String
    
    public init(
        name: NameDTO,
        capital: [String]?,
        currencies: [String: CurrencyDTO]?,
        languages: [String: String]?,
        flags: FlagsDTO,
        latlng: [Double]?,
        population: Int,
        area: Double?,
        region: String
    ) {
        self.name = name
        self.capital = capital
        self.currencies = currencies
        self.languages = languages
        self.flags = flags
        self.latlng = latlng
        self.population = population
        self.area = area
        self.region = region
    }
}

public struct NameDTO: Codable {
    public let common: String
    public let official: String
    public let nativeName: [String: NativeNameDTO]?
    
    public init(common: String, official: String, nativeName: [String: NativeNameDTO]?) {
        self.common = common
        self.official = official
        self.nativeName = nativeName
    }
}

public struct NativeNameDTO: Codable {
    public let official: String
    public let common: String
    
    public init(official: String, common: String) {
        self.official = official
        self.common = common
    }
}

public struct CurrencyDTO: Codable {
    public let name: String
    public let symbol: String
    
    public init(name: String, symbol: String) {
        self.name = name
        self.symbol = symbol
    }
}

public struct FlagsDTO: Codable {
    public let png: String
    public let svg: String
    
    public init(png: String, svg: String) {
        self.png = png
        self.svg = svg
    }
}
