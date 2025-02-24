// Country search view implementation
import SwiftUI
import Core

public struct CountrySearchView: View {
    @StateObject private var viewModel: CountrySearchViewModel
    private let onSelect: (Country) -> Void
    
    public init(viewModel: CountrySearchViewModel,
                onSelect: @escaping (Country) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSelect = onSelect
    }
    
    public var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.searchResults, id: \.id) { country in
                        Button {
                            onSelect(country)
                        } label: {
                            CountrySearchRow(country: country)
                        }
                    }
                    .overlay(Group {
                        if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 50))
                                    .padding(.bottom)
                                Text("No Results")
                                    .font(.title2)
                                Text("Try a different search term")
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    })
                }
            }
            .searchable(text: $viewModel.searchQuery,
                       placement: .navigationBarDrawer(displayMode: .always),
                       prompt: "Search countries")
            .navigationTitle("Search Country")
        }
    }
}

private struct CountrySearchRow: View {
    let country: Country
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(country.name.common)
                    .font(.headline)
            }
            
            if let capital = country.capital {
                Text(capital)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// End of file
