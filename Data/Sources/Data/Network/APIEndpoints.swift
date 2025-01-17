//
//  APIEndpoints.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

// MARK: - API Endpoints
public enum APIEndpoints {
    case allCountries
    case countryByName(String)
    case countryByRegion(String)
}

// MARK: - RequestConfigurable Implementation
extension APIEndpoints: RequestConfigurable {
    public var baseURL: String {
        return NetworkConfig.baseURL
    }
    
    public var path: String {
        switch self {
        case .allCountries:
            return NetworkConfig.Paths.allCountries
        case .countryByName(let name):
            return "\(NetworkConfig.Paths.countryByName)/\(name)"
        case .countryByRegion(let region):
            return "\(NetworkConfig.Paths.countryByRegion)/\(region)"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .allCountries, .countryByName, .countryByRegion:
            return .get
        }
    }
    
    public var headers: [String: String]? {
        return NetworkConfig.defaultHeaders
    }
    
    public var decoder: JSONDecoder? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

// MARK: - HTTP Method Enum
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
