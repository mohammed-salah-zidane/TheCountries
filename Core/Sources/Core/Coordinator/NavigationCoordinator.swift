// Navigation coordinator implementation for handling app navigation
import SwiftUI

// Sheet type definition moved outside for clarity
public enum NavigationSheet: Identifiable, Hashable {
    case search
    case error(String)
    
    public var id: String {
        switch self {
        case .search:
            return "search"
        case .error(let message):
            return "error_\(message)"
        }
    }
}

public protocol NavigationCoordinator: ObservableObject {
    var path: NavigationPath { get set }
    var presentedSheet: NavigationSheet? { get set }
    
    func showCountryDetails(_ country: Country)
    func presentCountrySearch()
    func presentError(_ message: String)
    func dismiss()
    func popToRoot()
}

public final class NavigationCoordinatorImpl: NavigationCoordinator {
    // MARK: - Published Properties
    @Published public var path = NavigationPath()
    @Published public var presentedSheet: NavigationSheet?
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - Public Methods
    public func showCountryDetails(_ country: Country) {
        // Use withAnimation for smooth transition
        withAnimation {
            path.append(country as Country)
        }
    }
    
    public func presentCountrySearch() {
        presentedSheet = .search
    }
    
    public func presentError(_ message: String) {
        presentedSheet = .error(message)
    }
    
    public func dismiss() {
        presentedSheet = nil
    }
    
    public func popToRoot() {
        path.removeLast(path.count)
    }
}
