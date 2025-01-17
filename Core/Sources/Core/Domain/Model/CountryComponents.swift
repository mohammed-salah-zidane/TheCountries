import Foundation

// MARK: - Supporting Domain Models

public struct CountryName: Equatable {
    public let common: String
    public let official: String
    
    public init(common: String, official: String) {
        self.common = common
        self.official = official
    }
}

public struct Currency: Equatable {
    public let name: String
    public let symbol: String
    
    public init(name: String, symbol: String) {
        self.name = name
        self.symbol = symbol
    }
}

public struct Coordinates: Equatable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
