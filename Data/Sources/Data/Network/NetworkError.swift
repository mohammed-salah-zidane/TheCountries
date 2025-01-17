//
//  NetworkError.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

// MARK: - Network Errors
public enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case requestFailed(statusCode: Int, data: Data?)
    case invalidResponse
    case decodingFailed(Error)
    case cancelled
    case timeout
    case noInternetConnection
    case unknown(Error)
    case notFound
    
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.cancelled, .cancelled),
             (.timeout, .timeout),
             (.noInternetConnection, .noInternetConnection),
             (.notFound, .notFound):
            return true
        case let (.requestFailed(lhsCode, lhsData), .requestFailed(rhsCode, rhsData)):
            return lhsCode == rhsCode && lhsData == rhsData
        case (.decodingFailed, .decodingFailed),
             (.unknown, .unknown):
            // Since Error doesn't conform to Equatable, we'll consider them equal
            // if they're the same case
            return true
        default:
            return false
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .requestFailed(let statusCode, _):
            return "Request failed with status code: \(statusCode)"
        case .invalidResponse:
            return "Received invalid response from server"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .cancelled:
            return "Request was cancelled"
        case .timeout:
            return "Request timed out"
        case .noInternetConnection:
            return "No internet connection available"
        case .notFound:
            return "Resource not found"
        case .unknown(let error):
            return "Unknown error occurred: \(error.localizedDescription)"
        }
    }
}
