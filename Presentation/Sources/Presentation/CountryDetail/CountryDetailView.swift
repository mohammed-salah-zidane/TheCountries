// Your imports remain the same
import SwiftUI
import Core

public struct CountryDetailView: View {
    // Properties remain the same
    private let country: Country
    
    public init(country: Country) {
        self.country = country
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Flag section remains the same
                if let flagUrl = country.flagUrl {
                    AsyncImage(url: flagUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 5)
                        case .failure:
                            Image(systemName: "flag.slash")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                                .frame(height: 200)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Content Sections
                VStack(spacing: 20) {
                    // General Information Card remains the same
                    InfoCard(title: "General Information") {
                        InfoRow(title: "Official Name", value: country.name.official)
                        if let capital = country.capital {
                            InfoRow(title: "Capital", value: capital)
                        }
                        InfoRow(title: "Region", value: country.region)
                        InfoRow(title: "Population", value: country.formattedPopulation)
                        if let area = country.formattedArea {
                            InfoRow(title: "Area", value: area)
                        }
                        if let coordinates = country.coordinates {
                            InfoRow(title: "Coordinates", value: coordinates.formatted)
                        }
                    }
                    
                    // Currency Card remains the same
                    if let currency = country.currency {
                        InfoCard(title: "Currency") {
                            InfoRow(title: "Name", value: currency.name)
                            InfoRow(title: "Symbol", value: currency.symbol)
                        }
                    }
                    
                    // Modified Languages Card with proper padding
                    if !country.languages.isEmpty {
                        InfoCard(title: "Languages") {
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 150), spacing: 12)
                            ], alignment: .leading, spacing: 12) {
                                ForEach(country.languages, id: \.self) { language in
                                    LanguageTag(language: language)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(country.name.common)
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
}

// InfoCard remains the same
private struct InfoCard<Content: View>: View {
    // Implementation remains the same
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 10) {
                content
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// InfoRow remains the same
private struct InfoRow: View {
    // Implementation remains the same
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// LanguageTag remains the same
private struct LanguageTag: View {
    let language: String
    
    var body: some View {
        Text(language)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.accentColor.opacity(0.1))
            .foregroundColor(.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
