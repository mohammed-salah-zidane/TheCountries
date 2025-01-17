import Foundation

// Domain model for Country
public struct Country: Identifiable, Equatable {
    public let id: String // We'll use the common name as identifier
    public let name: CountryName
    public let capital: String?
    public let currency: Currency?
    public let languages: [String]
    public let flagUrl: URL?
    public let coordinates: Coordinates?
    public let population: Int
    public let area: Double?
    public let region: String
    
    public init(
        id: String,
        name: CountryName,
        capital: String?,
        currency: Currency?,
        languages: [String],
        flagUrl: URL?,
        coordinates: Coordinates?,
        population: Int,
        area: Double?,
        region: String
    ) {
        self.id = id
        self.name = name
        self.capital = capital
        self.currency = currency
        self.languages = languages
        self.flagUrl = flagUrl
        self.coordinates = coordinates
        self.population = population
        self.area = area
        self.region = region
    }
}
