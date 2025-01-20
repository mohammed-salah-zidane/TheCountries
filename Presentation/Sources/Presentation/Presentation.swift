// The Swift Programming Language
// https://docs.swift.org/swift-book
// Presentation module main file
// This file serves as the main entry point and exports for the Presentation module

import SwiftUI
import Core

// MARK: - Base Components
/// Base protocol for all ViewModels
public protocol BaseViewModel: ObservableObject {
    /// Handles errors in the presentation layer
    func handleError(_ error: Error)
}

/// Base implementation for common ViewModel functionality
public class BaseViewModelImpl: BaseViewModel {
    public init() {}
    
    public func handleError(_ error: Error) {
        // TODO: Implement error handling strategy
        print("Error: \(error.localizedDescription)")
    }
}
