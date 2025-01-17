import Foundation

// MARK: - Network Configuration
public struct NetworkConfig {
    // Base configurations
    public static let baseURL = "https://restcountries.com/v3.1"
    public static let timeout: TimeInterval = 30
    
    // Default headers
    public static let defaultHeaders: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]
    
    // API paths
    public struct Paths {
        public static let allCountries = "/all"
        public static let countryByName = "/name"
        public static let countryByRegion = "/region"
    }
}
