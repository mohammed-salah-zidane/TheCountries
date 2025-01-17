// CountryDetailView implementation
import SwiftUI
import Core

public struct CountryDetailView: View {
    private let country: Country
    
    public init(country: Country) {
        self.country = country
    }
    
    public var body: some View {
        List {
            Section("General Information") {
                InfoRow(title: "Capital", value: country.capital ?? "N/A")
                InfoRow(title: "Region", value: country.region)
                InfoRow(title: "Population", value: country.formattedPopulation)
                if let area = country.formattedArea {
                    InfoRow(title: "Area", value: area)
                }
            }
            
            if let currency = country.currency {
                Section("Currency") {
                    InfoRow(title: "Name", value: currency.name)
                    InfoRow(title: "Symbol", value: currency.symbol)
                }
            }
            
            Section("Languages") {
                ForEach(country.languages, id: \.self) { language in
                    Text(language)
                }
            }
        }
        .navigationTitle(country.name.common)
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}

// End of file
