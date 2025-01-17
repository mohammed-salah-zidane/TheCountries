import Foundation
import Core

// MARK: - Mapper
public enum CountryMapper {
    // MARK: - Domain Mapping
    
    /// Maps a CountryDTO to a Country domain model
    /// - Parameter dto: The CountryDTO to map
    /// - Returns: A Country domain model
    /// - Throws: CoreError.invalidData if mapping fails
    public static func mapToDomain(dto: CountryDTO) -> Country {
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
    
    // MARK: - DTO Mapping
    
    /// Maps a Country domain model to a CountryDTO
    /// - Parameter country: The Country domain model to map
    /// - Returns: A CountryDTO
    /// - Throws: CoreError.invalidData if mapping fails
    public static func mapToDTO(country: Country) -> CountryDTO {
        // Create the Name DTO with nativeName
        let name = CountryDTO.Name(
            common: country.name.common,
            official: country.name.official,
            nativeName: [
                "eng": CountryDTO.Name.NativeName(
                    official: country.name.official,
                    common: country.name.common
                )
            ]
        )
        
        // Create a Currency DTO and wrap it in the required dictionary format
        let currencies: [String: CountryDTO.Currency]? = country.currency.map { currency in
            ["default": CountryDTO.Currency(name: currency.name, symbol: currency.symbol)]
        }
        
        // Create the capital array
        let capital: [String]? = country.capital.map { [$0] }
        
        // Create a dictionary of languages with unique keys
        let languages: [String: String]? = country.languages.isEmpty ? nil :
            Dictionary(uniqueKeysWithValues: country.languages.enumerated().map { index, language in
                ("lang_\(index)", language)
            })
        
        // Create the coordinates array
        let latlng = country.coordinates.map { [$0.latitude, $0.longitude] }
        
        // Create flags with both PNG and SVG URLs
        let flags = CountryDTO.Flags(
            png: country.flagUrl?.absoluteString ?? "",
            svg: country.flagUrl?.absoluteString.replacingOccurrences(of: ".png", with: ".svg") ?? ""
        )
        
        return CountryDTO(
            name: name,
            capital: capital,
            currencies: currencies,
            languages: languages,
            flags: flags,
            latlng: latlng,
            population: country.population,
            area: country.area,
            region: country.region,
            subregion: nil
        )
    }
}
