//
//  ContentView.swift
//  TheCountries
//
//  Created by Mohamed Salah on 14/01/2025.
//

import SwiftUI
import Core
import Presentation

struct ContentView: View {
    // Assembly to create our views and view models
    private let assembly: PresentationAssembly
    
    // Navigation coordinator for handling navigation
    @StateObject private var coordinator: NavigationCoordinatorImpl
    
    // MARK: - Initialization
    init(assembly: PresentationAssembly, coordinator: NavigationCoordinatorImpl) {
        self.assembly = assembly
        self._coordinator = StateObject(wrappedValue: coordinator)
    }
    
    // MARK: - Body
    var body: some View {
        assembly
            .makeHomeView()
            .sheet(item: $coordinator.presentedSheet, onDismiss: {
                // Handle sheet dismissal
                coordinator.dismiss()
            }) { sheet in
                ZStack {
                    // Background view to handle tap to dismiss
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            coordinator.dismiss()
                        }
                    
                    // Content based on sheet type
                    switch sheet {
                    case .search:
                        assembly.makeSearchView(onSelect: { country in
                            coordinator.showCountryDetails(country)
                            coordinator.dismiss()
                        })
                    case .error(let message):
                        ErrorView(message: message)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
    }
}

// MARK: - Preview
#Preview {
    // Create preview assemblies
    let coreAssembly = CoreAssembly()
    let presentationAssembly = PresentationAssembly(coreAssembly: coreAssembly)
    let coordinator = presentationAssembly.makeNavigationCoordinator()
    
    return ContentView(
        assembly: presentationAssembly,
        coordinator: coordinator
    )
}
