// Home screen view model implementation
import Foundation
import Core

public protocol HomeViewModelProtocol: ObservableObject {
    var countries: [Country] { get }
    var isLoading: Bool { get }
    var error: Error? { get }
    func addCountry(_ country: Country)
    func removeCountry(_ country: Country)
    func refreshLocation() async
}

// Enhanced ViewModelError with more specific cases
fileprivate enum ViewModelError: LocalizedError {
    case noDataAvailable
    case maxCountriesReached
    case locationServiceFailed
    case defaultCountryNotFound
    
    var errorDescription: String? {
        switch self {
        case .noDataAvailable:
            return "No data available"
        case .maxCountriesReached:
            return "Maximum number of countries (5) reached"
        case .locationServiceFailed:
            return "Unable to determine your location"
        case .defaultCountryNotFound:
            return "Default country could not be loaded"
        }
    }
}

@MainActor
public final class HomeViewModel: BaseViewModelImpl, @preconcurrency HomeViewModelProtocol {
    // MARK: - Constants
    let maxCountries = 5
    let defaultCountryName = "Egypt"
    
    // MARK: - Published Properties
    @Published private(set) public var countries: [Country] = []
    @Published private(set) public var isLoading = false
    @Published private(set) public var error: Error?
    
    // MARK: - Private Properties
    let fetchCountriesUseCase: FetchCountriesUseCase
    let searchCountriesUseCase: SearchCountriesUseCase
    let selectedCountriesUseCase: SelectedCountriesUseCase
    private let locationService: LocationService
    private var locationTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    
    // MARK: - Initialization
    public init(
        fetchCountriesUseCase: FetchCountriesUseCase,
        searchCountriesUseCase: SearchCountriesUseCase,
        selectedCountriesUseCase: SelectedCountriesUseCase,
        locationService: LocationService
    ) {
        self.fetchCountriesUseCase = fetchCountriesUseCase
        self.searchCountriesUseCase = searchCountriesUseCase
        self.selectedCountriesUseCase = selectedCountriesUseCase
        self.locationService = locationService
        super.init()
        
        // Initialize with saved data and location
        startInitialization()
    }
    
    deinit {
        locationTask?.cancel()
        refreshTask?.cancel()
    }
    
    // MARK: - Private Methods
    private func startInitialization() {
        // Cancel any existing task
        locationTask?.cancel()
        
        // Start new initialization task
        locationTask = Task { @MainActor [weak self] in
            await self?.initializeData()
        }
    }
    
    private func initializeData() async {
        // Check if task is cancelled
        guard !Task.isCancelled else {
            isLoading = false
            return
        }
        
        isLoading = true
        error = nil
        
        // Step 1: Try to load saved countries
        do {
            let savedCountries = try await selectedCountriesUseCase.fetchSelectedCountries()
            if !savedCountries.isEmpty {
                countries = savedCountries
                isLoading = false
                return
            }
        } catch {
            // Continue to location-based loading if saved data fails
        }
        
        // Check if task is cancelled
        guard !Task.isCancelled else {
            isLoading = false
            return
        }
        
        // Step 2: Try to get country by location
        do {
            let locationCountry = try await locationService.getCurrentCountry()
            if !Task.isCancelled {
                countries = [locationCountry]
                try? await selectedCountriesUseCase.saveSelectedCountries(countries)
                isLoading = false
                return
            }
        } catch {
            // Continue to default country if location fails
        }
        
        // Check if task is cancelled
        guard !Task.isCancelled else {
            isLoading = false
            return
        }
        
        // Step 3: Load default country as fallback
        await loadDefaultCountry()
    }
    
    private func loadDefaultCountry() async {
        guard !Task.isCancelled else {
            isLoading = false
            return
        }
        
        do {
            let defaultName = defaultCountryName.lowercased()
            let searchResults = try await searchCountriesUseCase.execute(query: defaultName)
            
            guard !Task.isCancelled else {
                isLoading = false
                return
            }
            
            if let country = searchResults.first(where: {
                $0.name.common.lowercased() == defaultName
            }) {
                countries = [country]
                try? await selectedCountriesUseCase.saveSelectedCountries(countries)
            } else {
                error = ViewModelError.defaultCountryNotFound
            }
        } catch {
            if !Task.isCancelled {
                self.error = ViewModelError.defaultCountryNotFound
                handleError(error)
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Public Methods
    public func addCountry(_ country: Country) {
        guard countries.count < maxCountries else {
            error = ViewModelError.maxCountriesReached
            return
        }
        guard !countries.contains(where: { $0.id == country.id }) else { return }
        
        countries.append(country)
        Task {
            try? await selectedCountriesUseCase.saveSelectedCountries(countries)
        }
    }
    
    public func removeCountry(_ country: Country) {
        countries.removeAll(where: { $0.id == country.id })
        
        Task {
            if countries.isEmpty {
                try? await selectedCountriesUseCase.clearSelectedCountries()
                // Automatically load default country when list becomes empty
                await loadDefaultCountry()
            } else {
                try? await selectedCountriesUseCase.saveSelectedCountries(countries)
            }
        }
    }
    
    public func refreshLocation() async {
        // Cancel any existing refresh task
        refreshTask?.cancel()
        
        // Start new refresh task
        refreshTask = Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            self.isLoading = true
            self.error = nil
            
            do {
                let country = try await self.locationService.getCurrentCountry()
                if !Task.isCancelled {
                    if !self.countries.contains(where: { $0.id == country.id }) {
                        self.addCountry(country)
                    }
                }
            } catch {
                if !Task.isCancelled {
                    self.error = ViewModelError.locationServiceFailed
                    self.handleError(error)
                }
            }
            
            if !Task.isCancelled {
                self.isLoading = false
            }
        }
    }
}
