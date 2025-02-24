import SwiftUI
import Core

public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var coordinator: NavigationCoordinatorImpl
    
    public init(viewModel: HomeViewModel, coordinator: NavigationCoordinatorImpl) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _coordinator = StateObject(wrappedValue: coordinator)
    }
    
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            List {
                if viewModel.isLoading {
                    loadingView
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                        .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height - 200)
                } else if !viewModel.countries.isEmpty {
                    countriesList
                } else {
                    emptyStateView
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                        .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height - 200)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .listStyle(.plain)
            .ignoresSafeArea(.container, edges: .bottom)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Countries")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .toolbar { addCountryToolbarItem }
            .errorAlert(error: viewModel.error)
            .refreshable { await viewModel.refreshLocation() }
            .sheet(item: $coordinator.presentedSheet, content: sheetContent)
            .navigationDestination(for: Country.self) { country in
                CountryDetailView(country: country)
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading Countries...")
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Countries List
    private var countriesList: some View {
        ForEach(viewModel.countries) { country in
            Button(action: { coordinator.showCountryDetails(country) }) {
                CountryRowView(country: country)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .swipeActions {
                Button(role: .destructive) {
                    withAnimation { viewModel.removeCountry(country) }
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            }
            .listRowSeparator(.hidden)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "globe")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            
            Text("No Countries Added")
                .font(.title2.bold())
            
            Text("Tap the + button to add countries to your list")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Toolbar Items
    private var addCountryToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.countries.count < viewModel.maxCountries {
                Button(action: { coordinator.presentCountrySearch() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.blue)
                }
            }
        }
    }
    
    // MARK: - Sheet Content
    @ViewBuilder
    private func sheetContent(_ sheet: NavigationSheet) -> some View {
        switch sheet {
        case .search:
            CountrySearchView(
                viewModel: .init(searchCountriesUseCase: viewModel.searchCountriesUseCase),
                onSelect: { country in
                    viewModel.addCountry(country)
                    coordinator.dismiss()
                }
            )
        case .error(let message):
            ErrorView(message: message)
        }
    }
}

private struct CountryRowView: View {
    let country: Country
    
    var body: some View {
        HStack(spacing: 16) {
            flagView
                .frame(width: 60, height: 40)
                .cornerRadius(8)
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(country.name.common)
                    .font(.headline)
                
                if let capital = country.capital {
                    Text(capital)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var flagView: some View {
        Group {
            if let flagUrl = country.flagUrl {
                AsyncImage(url: flagUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        Image(systemName: "flag.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        Image(systemName: "flag.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Image(systemName: "flag.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 60, height: 40)
        .background(Color(.systemGray5))
    }
}

extension View {
    func errorAlert(error: Error?) -> some View {
        let isPresented = Binding(
            get: { error != nil },
            set: { _ in }
        )
        
        return alert("Error",
                     isPresented: isPresented,
                     presenting: error) { _ in
            Button("OK", role: .cancel) { }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}
