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

// Define ViewModelError
fileprivate enum ViewModelError: LocalizedError {
    case noDataAvailable
    
    var errorDescription: String? {
        switch self {
        case .noDataAvailable:
            return "No data available"
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
        
        locationTask = Task { @MainActor [weak self] in
            await self?.loadInitialData()
        }
    }
    
    deinit {
        locationTask?.cancel()
    }
    
    // MARK: - Private Methods
    private func loadInitialData() async {
        do {
            let savedCountries = try await selectedCountriesUseCase.fetchSelectedCountries()
            countries = savedCountries
            
            if countries.isEmpty {
                await loadDefaultCountry()
            }
        } catch {
            await loadDefaultCountry()
        }
    }
    
    private func loadInitialCountry() async {
        await loadCurrentLocation()
        
        if countries.isEmpty {
            await loadDefaultCountry()
        }
    }
    
    private func loadCurrentLocation() async {
        isLoading = true
        error = nil
        
        do {
//            let countryResult = try await locationService.getCurrentCountry()
//            let countryId = countryResult.id
//            if !countries.contains(where: { $0.id == countryId }) {
//                countries.append(countryResult)
//                try? await selectedCountriesUseCase.saveSelectedCountries(countries)
//            }
        } catch {
            self.error = error
            handleError(error)
        }
        
        isLoading = false
    }
    
    private func loadDefaultCountry() async {
        isLoading = true
        error = nil
        
        do {
            let defaultName = defaultCountryName.lowercased()
            let searchResults = try await searchCountriesUseCase.execute(query: defaultName)
            
            let filteredCountry = searchResults.first { country in
                country.name.common.lowercased() == defaultName
            }
            
            if let country = filteredCountry {
                let countryId = country.id
                if !countries.contains(where: { $0.id == countryId }) {
                    countries.append(country)
                    // Save default country to cache when added
                    try? await selectedCountriesUseCase.saveSelectedCountries(countries)
                }
            }
        } catch {
            self.error = error
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Public Methods
    public func addCountry(_ country: Country) {
        guard countries.count < maxCountries else { return }
        guard !countries.contains(where: { $0.id == country.id }) else { return }
        countries.append(country)
        Task {
            try? await selectedCountriesUseCase.saveSelectedCountries(countries)
        }
    }
    
    public func removeCountry(_ country: Country) {
        countries.removeAll(where: { $0.id == country.id })
        // Save the updated list after removal
        Task {
            if countries.isEmpty {
                try? await selectedCountriesUseCase.clearSelectedCountries()
            } else {
                try? await selectedCountriesUseCase.saveSelectedCountries(countries)
            }
        }
    }
    
    public func refreshLocation() async {
        await loadCurrentLocation()
    }
}
