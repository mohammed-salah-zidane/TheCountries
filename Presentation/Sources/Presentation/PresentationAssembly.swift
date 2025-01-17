// Dependency injection container for presentation module
import Foundation
import Core

// MARK: - Assembly Protocol
public protocol CoreAssemblyProvider {
    func makeFetchCountriesUseCase() -> FetchCountriesUseCase
    func makeSearchCountriesUseCase() -> SearchCountriesUseCase
}

@MainActor
public final class PresentationAssembly {
    private let coreAssembly: CoreAssemblyProvider
    
    public init(coreAssembly: CoreAssemblyProvider) {
        self.coreAssembly = coreAssembly
    }
    
    // MARK: - Services
    public func makeLocationService() -> LocationService {
        LocationService()
    }
    
    public func makeNavigationCoordinator() -> NavigationCoordinatorImpl {
        NavigationCoordinatorImpl()
    }
    
    // MARK: - ViewModels
    public func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            fetchCountriesUseCase: coreAssembly
                .makeFetchCountriesUseCase(),
            searchCountriesUseCase: coreAssembly
                .makeSearchCountriesUseCase(),
            locationService: makeLocationService()
        )
    }

    
    public func makeSearchViewModel() -> CountrySearchViewModel {
        CountrySearchViewModel(
            searchCountriesUseCase: coreAssembly.makeSearchCountriesUseCase()
        )
    }
    
    // MARK: - Views
    public func makeHomeView() -> HomeView {
        HomeView(
            viewModel: makeHomeViewModel(),
            coordinator: makeNavigationCoordinator()
        )
    }
    
    public func makeSearchView(onSelect: @escaping @MainActor (Country) -> Void) -> CountrySearchView {
        CountrySearchView(
            viewModel: makeSearchViewModel(),
            onSelect: onSelect
        )
    }
    
    public func makeDetailView(country: Country) -> CountryDetailView {
        CountryDetailView(country: country)
    }
}
