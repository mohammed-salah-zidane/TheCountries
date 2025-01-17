// Country search view model implementation
import Foundation
import Core
import Combine

// Protocol definition
public protocol CountrySearchViewModelProtocol: ObservableObject {
    var searchResults: [Country] { get }
    var isLoading: Bool { get }
    var searchQuery: String { get set }
    var hasError: Bool { get }
    func performSearch(query: String)
}

@MainActor
public final class CountrySearchViewModel: BaseViewModelImpl, @preconcurrency CountrySearchViewModelProtocol {
    // MARK: - Published Properties
    @Published private(set) public var searchResults: [Country] = []
    @Published private(set) public var isLoading = false
    @Published public var searchQuery = "" {
        didSet {
            performSearch(query: searchQuery)
        }
    }
    @Published private(set) public var hasError = false
    
    // MARK: - Private Properties
    private let searchCountriesUseCase: any SearchCountriesUseCaseProtocol
    private var currentTask: Task<Void, Never>?
    
    // MARK: - Initialization
    public init(searchCountriesUseCase: any SearchCountriesUseCaseProtocol) {
        self.searchCountriesUseCase = searchCountriesUseCase
        super.init()
    }
    
    deinit {
        currentTask?.cancel()
    }
    
    // MARK: - Public Methods
    public func performSearch(query: String) {
        // Cancel any existing search
        currentTask?.cancel()
        
        guard !query.isEmpty else {
            // Already on MainActor, can update state directly
            searchResults = []
            isLoading = false
            return
        }
        
        // Start new search task
        isLoading = true
        hasError = false
        
        let useCase = searchCountriesUseCase // Capture useCase locally
        
        currentTask = Task { @MainActor [weak self] in
            guard let self else { return }
            
            do {
                // Add debounce delay
                try await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
                guard !Task.isCancelled else { return }
                
                // Execute search in a separate async context without capturing self
                let results = try await useCase.execute(query: query)
                
                guard !Task.isCancelled else { return }
                
                // Update results (already on MainActor)
                self.searchResults = results
                self.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                
                // Handle error (already on MainActor)
                self.searchResults = []
                self.hasError = true
                self.isLoading = false
                self.handleError(error)
            }
        }
    }
}
