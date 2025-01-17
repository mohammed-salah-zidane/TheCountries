// Your imports
import Foundation
import Core
import Data
import Presentation

// MARK: - Core Assembly Implementation
public final class CoreAssembly: CoreAssemblyProvider {
    private let repository: CountryRepositoryProtocol
    private let cachePolicy: CachePolicyProtocol
    
    public init() {
        // Initialize network client
        let networkClient = NetworkClient()
        
        // Initialize data sources
        let remoteDataSource = RemoteCountryDataSourceImpl(networkClient: networkClient)
        let localDataSource = LocalCountryDataSourceImpl()
        
        // Initialize repository
        self.repository = CountryRepository(
            remoteDataSource: remoteDataSource,
            localDataSource: localDataSource
        )
        
        // Initialize cache policy
        self.cachePolicy = DefaultCachePolicy()
    }
    
    public func makeFetchCountriesUseCase() -> Core.FetchCountriesUseCase {
        FetchCountriesUseCase(
            repository: repository,
            cachePolicy: cachePolicy
        )
    }
    
    public func makeSearchCountriesUseCase() -> Core.SearchCountriesUseCase {
        SearchCountriesUseCase(
            repository: repository
        )
    }
}
