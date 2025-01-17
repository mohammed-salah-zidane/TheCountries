//
//  TheCountriesApp.swift
//  TheCountries
//
//  Created by Mohamed Salah on 14/01/2025.
//

import SwiftUI
import Core
import Data
import Presentation

@main
struct TheCountriesApp: App {
    // Initialize assemblies and coordinator
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                assembly: appState.presentationAssembly,
                coordinator: appState.coordinator
            )
        }
    }
}

// MARK: - App State
@MainActor
final class AppState: ObservableObject {
    // MARK: - Properties
    let coreAssembly: CoreAssembly
    let presentationAssembly: PresentationAssembly
    @Published var coordinator: NavigationCoordinatorImpl
    
    // MARK: - Initialization
    init() {
        // Initialize core assembly
        self.coreAssembly = CoreAssembly()
        
        // Initialize presentation assembly with core assembly
        self.presentationAssembly = PresentationAssembly(coreAssembly: coreAssembly)
        
        // Initialize coordinator
        self.coordinator = presentationAssembly.makeNavigationCoordinator()
    }
}
