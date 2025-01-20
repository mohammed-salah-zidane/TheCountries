import Foundation

// MARK: - Supporting Domain Models

public struct CountryName: Equatable, Codable, Sendable {
    public let common: String
    public let official: String
    
    public init(common: String, official: String) {
        self.common = common
        self.official = official
    }
}

public struct Currency: Equatable, Codable, Sendable {
    public let name: String
    public let symbol: String
    
    public init(name: String, symbol: String) {
        self.name = name
        self.symbol = symbol
    }
    
    /// Returns a formatted string with currency name and symbol
    public var formatted: String {
        return "\(name) (\(symbol))"
    }
}

public struct Coordinates: Equatable, Codable, Sendable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /// Returns a formatted string with coordinates
    public var formatted: String {
        let formatter = createNumberFormatter()
        
        let lat = formatter.string(from: NSNumber(value: latitude)) ?? String(latitude)
        let lon = formatter.string(from: NSNumber(value: longitude)) ?? String(longitude)
        
        return "\(lat)°, \(lon)°"
    }
    
    /// Returns coordinates as a tuple
    public var tuple: (latitude: Double, longitude: Double) {
        return (latitude, longitude)
    }
    
    // MARK: - Private Methods
    
    private func createNumberFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.locale = .current
        return formatter
    }
}
