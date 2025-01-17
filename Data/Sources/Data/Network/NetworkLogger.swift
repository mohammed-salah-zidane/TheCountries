//
//  NetworkLogger.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation
import os.log

// MARK: - NetworkLogger Protocol
public protocol NetworkLoggerProtocol {
    func logRequest(_ request: URLRequest)
    func logResponse(_ response: URLResponse?, data: Data?, error: Error?)
    func logError(_ error: Error)
}

// MARK: - NetworkLogger Implementation
public class NetworkLogger: NetworkLoggerProtocol {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app.networking",
                               category: "NetworkLogger")
    
    public init() {}
    
    public func logRequest(_ request: URLRequest) {
        let timestamp = Date().description
        var logMessage = ""
        
        // Request basics
        logMessage += "\n📤 [\(timestamp)] OUTGOING REQUEST"
        logMessage += "\n📌 URL: \(request.url?.absoluteString ?? "nil")"
        logMessage += "\n📝 Method: \(request.httpMethod ?? "nil")"
        
        // Headers
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            logMessage += "\n📋 Headers:\n\(formatDictionary(headers))"
        }
        
        // Body
        if let body = request.httpBody,
           let json = try? JSONSerialization.jsonObject(with: body, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            logMessage += "\n📦 Body:\n\(prettyString)"
        }
        
        logger.debug("\(logMessage)")
    }
    
    public func logResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        let timestamp = Date().description
        var logMessage = ""
        
        logMessage += "\n📥 [\(timestamp)] INCOMING RESPONSE"
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusEmoji = httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 ? "✅" : "⚠️"
            logMessage += "\n\(statusEmoji) Status: \(httpResponse.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
            
            // Response Headers
            if let headers = httpResponse.allHeaderFields as? [String: Any] {
                logMessage += "\n📋 Headers:\n\(formatDictionary(headers))"
            }
        }
        
        // Response Body
        if let data = data {
            logMessage += "\n📦 Size: \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .binary))"
            
            if let json = try? JSONSerialization.jsonObject(with: data),
               let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                logMessage += "\n📝 Body:\n\(prettyString)"
            }
        }
        
        if let error = error {
            logMessage += "\n❌ Error: \(error.localizedDescription)"
        }
        
        logger.debug("\(logMessage)")
    }
    
    public func logError(_ error: Error) {
        logger.error("❌ Network Error: \(error.localizedDescription)")
    }
    
    // MARK: - Helper Methods
    private func formatDictionary(_ dictionary: [String: Any]) -> String {
        dictionary.map { "  \($0.key): \($0.value)" }.joined(separator: "\n")
    }
}
