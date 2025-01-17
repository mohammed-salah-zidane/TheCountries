import Foundation

// Domain model for Country
public struct Country: Identifiable, Equatable, Codable, Sendable, Hashable {
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
    
    /// Returns a display-friendly version of the country's population
    public var formattedPopulation: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: population)) ?? String(population)
    }
    
    /// Returns a display-friendly version of the country's area
    public var formattedArea: String? {
        guard let area = area else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: area)).map { "\($0) km²" }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Country {
    /// Filters countries based on a search query
    /// - Parameter query: The search query to match against
    /// - Returns: Boolean indicating if country matches the query
    public func matches(query: String) -> Bool {
        let searchText = query.lowercased()
        return name.common.lowercased().contains(searchText) ||
            name.official.lowercased().contains(searchText) ||
            capital?.lowercased().contains(searchText) ?? false ||
            region.lowercased().contains(searchText)
    }
}

extension Country {
    /// Sorting criteria for countries
    public enum SortCriteria {
        case name
        case population
        case area
        case region
    }
    
    /// Returns a comparator function for the given sort criteria
    /// - Parameter criteria: The criteria to sort by
    /// - Returns: A comparison function for two countries
    public static func comparator(for criteria: SortCriteria) -> (Country, Country) -> Bool {
        switch criteria {
        case .name:
            return { $0.name.common < $1.name.common }
        case .population:
            return { $0.population > $1.population }
        case .area:
            return { ($0.area ?? 0) > ($1.area ?? 0) }
        case .region:
            return { $0.region < $1.region }
        }
    }
}
