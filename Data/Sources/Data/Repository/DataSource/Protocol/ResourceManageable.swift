//
//  ResourceManageable.swift
//  Core
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

// MARK: - Resource Manageable Protocol
public protocol ResourceManageable {
    /// Cleans up any resources held by the implementer
    func cleanup()
    
    /// Releases any cached data to free memory
    func releaseMemory()
    
    /// Prepares the implementer for background operation
    func prepareForBackground()
    
    /// Restores the implementer for foreground operation
    func restoreForForeground()
}

// MARK: - Default Implementation
public extension ResourceManageable {
    func cleanup() {}
    func releaseMemory() {}
    func prepareForBackground() {}
    func restoreForForeground() {}
}

