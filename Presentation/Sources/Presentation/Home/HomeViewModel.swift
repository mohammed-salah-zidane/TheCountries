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
    private let defaultCountryName = "Egypt"
    
    // MARK: - Published Properties
    @Published private(set) public var countries: [Country] = []
    @Published private(set) public var isLoading = false
    @Published private(set) public var error: Error?
    
    // MARK: - Use Cases & Services
    let fetchCountriesUseCase: FetchCountriesUseCase
    let searchCountriesUseCase: SearchCountriesUseCase
    let selectedCountriesUseCase: SelectedCountriesUseCase
    let locationService: LocationService
    
    // MARK: - Tasks
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
        
        // Kick off data loading
        startInitialization()
    }
    
    deinit {
        locationTask?.cancel()
        refreshTask?.cancel()
    }
    
    // MARK: - Private Methods
    
    /// Initiates the async sequence: load saved → location → default
    private func startInitialization() {
        locationTask?.cancel()
        
        locationTask = Task {
            await initializeData()
        }
    }
    
    /// Full initialization:
    /// 1) Load saved countries
    /// 2) If empty, try location
    /// 3) If location fails, load default
    private func initializeData() async {
        guard !Task.isCancelled else { return }
        isLoading = true
        error = nil
        
        // 1) Try loading saved countries
        do {
            let savedCountries = try await selectedCountriesUseCase.fetchSelectedCountries()
            if !savedCountries.isEmpty {
                countries = savedCountries
                isLoading = false
                return
            }
        } catch {
            // If it fails, we simply move on to location
            // (no error displayed yet, because we can try location or default next).
        }
        
        guard !Task.isCancelled else { return }
        
        // 2) Try fetching location-based country
        do {
            let country = try await locationService.getCurrentCountry()
            let remoteCountry = try await searchCountriesUseCase.execute(
                query: country.name.common
            )
            if remoteCountry.isEmpty {
                countries = [country]
            }else {
                countries = remoteCountry
            }
            try? await selectedCountriesUseCase.saveSelectedCountries(countries)
            isLoading = false
            return
        } catch {
            // If location fails, we log it (if you wish) but do not set error yet,
            // we’ll fallback to default next.
        }
        
        guard !Task.isCancelled else { return }
        
        // 3) Load default country as a final fallback
        await loadDefaultCountry()
    }
    
    /// Loads the default country by name (e.g. "Egypt").
    private func loadDefaultCountry() async {
        defer { isLoading = false }
        
        do {
            let lowercasedDefault = defaultCountryName.lowercased()
            let searchResults = try await searchCountriesUseCase.execute(query: lowercasedDefault)
            
            guard let found = searchResults.first(where: {
                $0.name.common.lowercased() == lowercasedDefault
            }) else {
                self.error = ViewModelError.defaultCountryNotFound
                return
            }
            
            // If found, make it the only country in the list
            countries = [found]
            try? await selectedCountriesUseCase.saveSelectedCountries(countries)
        } catch {
            self.error = ViewModelError.defaultCountryNotFound
            handleError(error)
        }
    }
    
    // MARK: - Public API
    
    /// Adds a new country if we haven’t reached `maxCountries` and we don’t already have it.
    public func addCountry(_ country: Country) {
        guard countries.count < maxCountries else {
            error = ViewModelError.maxCountriesReached
            return
        }
        guard !countries.contains(where: { $0.id == country.id }) else {
            return // Already in the list; ignore
        }
        
        countries.append(country)
        
        Task {
            try? await selectedCountriesUseCase.saveSelectedCountries(countries)
        }
    }
    
    /// Removes a country. If the list becomes empty, we load the default country again.
    public func removeCountry(_ country: Country) {
        countries.removeAll(where: { $0.id == country.id })
        
        Task {
            if countries.isEmpty {
                try? await selectedCountriesUseCase.clearSelectedCountries()
                await loadDefaultCountry()
            } else {
                try? await selectedCountriesUseCase.saveSelectedCountries(countries)
            }
        }
    }
    
    /// Refreshes the user’s location, attempting to add the new location country if different.
    /// If location fails, sets `error = .locationServiceFailed`.
    public func refreshLocation() async {
        // Cancel any previous refresh attempts
        refreshTask?.cancel()
        
        refreshTask = Task { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = true
            self.error = nil
            
            do {
                let newLocationCountry = try await self.locationService.getCurrentCountry()
                
                // If not already in the list, add it
                if !self.countries.contains(where: { $0.id == newLocationCountry.id }) {
                    self.addCountry(newLocationCountry)
                }
            } catch {
                self.error = ViewModelError.locationServiceFailed
                self.handleError(error)
            }
            
            self.isLoading = false
        }
    }
}
