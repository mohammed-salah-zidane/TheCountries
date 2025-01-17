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
    private let locationService: LocationService
    private var locationTask: Task<Void, Never>?
    
    // MARK: - Initialization
    public init(
        fetchCountriesUseCase: FetchCountriesUseCase,
        searchCountriesUseCase: SearchCountriesUseCase,
        locationService: LocationService
    ) {
        self.fetchCountriesUseCase = fetchCountriesUseCase
        self.searchCountriesUseCase = searchCountriesUseCase
        self.locationService = locationService
        super.init()
        
        locationTask = Task { @MainActor [weak self] in
            await self?.loadInitialCountry()
        }
    }
    
    deinit {
        locationTask?.cancel()
    }
    
    // MARK: - Private Methods
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
    }
    
    public func removeCountry(_ country: Country) {
        countries.removeAll(where: { $0.id == country.id })
    }
    
    public func refreshLocation() async {
        await loadCurrentLocation()
    }
}
