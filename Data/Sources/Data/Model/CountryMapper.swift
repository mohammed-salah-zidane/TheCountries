import Foundation
import Core

// MARK: - Mapper
public struct CountryMapper {
    public static func mapToDomain(_ dto: CountryDTO) -> Country {
        // Extract the first currency if available
        let firstCurrency = dto.currencies?.first.map { (_, value) in
            Currency(name: value.name, symbol: value.symbol)
        }
        
        // Extract coordinates if available
        let coordinates = dto.latlng.flatMap { latlng -> Coordinates? in
            guard latlng.count >= 2 else { return nil }
            return Coordinates(latitude: latlng[0], longitude: latlng[1])
        }
        
        return Country(
            id: dto.name.common,
            name: CountryName(common: dto.name.common, official: dto.name.official),
            capital: dto.capital?.first,
            currency: firstCurrency,
            languages: dto.languages?.values.map { $0 } ?? [],
            flagUrl: URL(string: dto.flags.png),
            coordinates: coordinates,
            population: dto.population,
            area: dto.area,
            region: dto.region
        )
    }
}
