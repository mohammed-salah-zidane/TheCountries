//
//  PersistentStorage.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

// MARK: - Storage Protocol
public protocol PersistentStorage {
    func save<T: Codable>(_ item: T, forKey key: String) async throws
    func fetch<T: Codable>(forKey key: String) async throws -> T
    func remove(forKey key: String) async throws
    func exists(forKey key: String) async -> Bool
}

// MARK: - UserDefaults Storage Implementation
public final class UserDefaultsStorage: PersistentStorage {
    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    public init(
        userDefaults: UserDefaults = .standard,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
    }
    
    public func save<T: Codable>(_ item: T, forKey key: String) async throws {
        do {
            let data = try encoder.encode(item)
            userDefaults.set(data, forKey: key)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
    
    public func fetch<T: Codable>(forKey key: String) async throws -> T {
        guard let data = userDefaults.data(forKey: key) else {
            throw NetworkError.notFound
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
    
    public func remove(forKey key: String) async throws {
        userDefaults.removeObject(forKey: key)
    }
    
    public func exists(forKey key: String) async -> Bool {
        return userDefaults.object(forKey: key) != nil
    }
}
