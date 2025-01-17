import Foundation

// Make DTOs public
public struct CountryDTO: Codable, Sendable, Equatable {
    public let name: CountryDTO.Name
    public let capital: [String]?
    public let currencies: [String: CountryDTO.Currency]?
    public let languages: [String: String]?
    public let flags: CountryDTO.Flags
    public let latlng: [Double]?
    public let population: Int
    public let area: Double?
    public let region: String
    public let subregion: String?

    public init(
        name: CountryDTO.Name,
        capital: [String]?,
        currencies: [String: CountryDTO.Currency]?,
        languages: [String: String]?,
        flags: CountryDTO.Flags,
        latlng: [Double]?,
        population: Int,
        area: Double?,
        region: String,
        subregion: String?
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
        self.subregion = subregion
    }

    public struct Name: Codable, Sendable, Equatable {
        public let common: String
        public let official: String
        public let nativeName: [String: CountryDTO.Name.NativeName]?

        public init(common: String, official: String, nativeName: [String: CountryDTO.Name.NativeName]?) {
            self.common = common
            self.official = official
            self.nativeName = nativeName
        }

        public struct NativeName: Codable, Sendable, Equatable {
            public let official: String
            public let common: String

            public init(official: String, common: String) {
                self.official = official
                self.common = common
            }
        }
    }

    public struct Currency: Codable, Sendable, Equatable {
        public let name: String
        public let symbol: String

        public init(name: String, symbol: String) {
            self.name = name
            self.symbol = symbol
        }
    }

    public struct Flags: Codable, Sendable, Equatable {
        public let png: String
        public let svg: String

        public init(png: String, svg: String) {
            self.png = png
            self.svg = svg
        }
    }
}
