import Foundation
import CoreLocation

/// A service that fetches a `Country` object using the user’s GPS location.
/// The class is constrained to the main actor because CLLocationManager
/// must be used on the main thread (UI).
public final class LocationService: NSObject, CLLocationManagerDelegate {

    // MARK: - Private Properties

    private let locationManager: CLLocationManager
    private var geocoder: CLGeocoder?
    
    /// Continuation for waiting on authorization.
    private var authContinuation: CheckedContinuation<Void, Error>?
    /// Continuation for waiting on a location fix / geocoding.
    private var locationContinuation: CheckedContinuation<Country, Error>?

    // MARK: - Initialization

    public override init() {
        self.locationManager = CLLocationManager()
        super.init()
        
        self.locationManager.delegate = self
        // Optional: control accuracy/distance
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.distanceFilter = 500
    }
    
    // MARK: - Public API

    /// Main entry point: asynchronously fetch the current `Country`.
    /// 1) Requests authorization if `.notDetermined`, and waits for user’s choice.
    /// 2) If authorized, starts updating location and awaits the first location fix.
    /// 3) Reverse-geocodes to produce a `Country` object, or throws if it fails.
    ///
    /// - Throws: `LocationError.permissionDenied` if the user denies or location is restricted,
    ///           `LocationError.geocodingFailed` if no valid country is found,
    ///           or any lower-level geocoding error.
    /// - Returns: A `Country` object representing the user’s current location.
    @MainActor
    public func getCurrentCountry() async throws -> Country {
        // Step 1: Ensure we have (or get) authorization
        try await requestAuthorizationIfNeeded()
        
        // Step 2: Start location updates and await the geocoded Country
        locationManager.startUpdatingLocation()
        
        return try await withCheckedThrowingContinuation { cont in
            // Store the location continuation so we can resume it in delegate callbacks.
            self.locationContinuation = cont
        }
    }
    
    // MARK: - Private Helpers
    
    /// Requests `whenInUse` authorization **if** not determined, suspending until the user
    /// responds to the system prompt. Throws if the user denies or restricted.
    @MainActor
    private func requestAuthorizationIfNeeded() async throws {
        // If we’re already authorized, just return.
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
        case .denied, .restricted:
            // Already known to be denied or restricted
            throw LocationError.permissionDenied
        case .notDetermined:
            // We must request permission and wait for the user’s response
            return try await withCheckedThrowingContinuation { cont in
                self.authContinuation = cont
                locationManager.requestWhenInUseAuthorization()
            }
        @unknown default:
            throw LocationError.permissionDenied
        }
    }
    
    /// Cancels any ongoing operations (stops location, cancels geocode, clears continuations).
    private func cleanup() {
        locationManager.stopUpdatingLocation()
        geocoder?.cancelGeocode()
        geocoder = nil
        
        // If either continuation hasn’t resumed yet, we nil it out.
        // (Never forcibly resume it a second time.)
        authContinuation = nil
        locationContinuation = nil
    }
    
    // MARK: - CLLocationManagerDelegate

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // If we’re waiting for an authorization decision:
        guard let authContinuation = authContinuation else { return }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // User granted permission -> resume the continuation
            authContinuation.resume(returning: ())
            self.authContinuation = nil
        case .denied, .restricted:
            // User denied or restricted -> fail
            authContinuation.resume(throwing: LocationError.permissionDenied)
            self.authContinuation = nil
        case .notDetermined:
            // Still no user decision; do nothing. We'll remain suspended.
            break
        @unknown default:
            // For future new states, treat as denied.
            authContinuation.resume(throwing: LocationError.permissionDenied)
            self.authContinuation = nil
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let cont = locationContinuation else { return }
        guard let location = locations.first else {
            cont.resume(throwing: LocationError.geocodingFailed)
            cleanup()
            return
        }
        
        // Stop updates to prevent multiple callbacks.
        locationManager.stopUpdatingLocation()
        
        // Reverse geocode
        let geocoder = CLGeocoder()
        self.geocoder = geocoder
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            guard let cont = self.locationContinuation else { return }
            
            defer {
                self.cleanup()
            }
            
            if let error = error {
                cont.resume(throwing: error)
                return
            }
            
            guard
                let placemark = placemarks?.first,
                let countryCode = placemark.isoCountryCode,
                let countryName = placemark.country
            else {
                cont.resume(throwing: LocationError.geocodingFailed)
                return
            }
            
            // Build a Country from placemark
            let country = Country(
                id: countryCode,
                name: CountryName(
                    common: countryName,
                    official: countryName
                ),
                capital: placemark.locality,
                currency: nil, // Not available from CLGeocoder
                languages: [],
                flagUrl: nil,
                coordinates: Coordinates(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                ),
                population: 0,
                area: nil,
                region: placemark.administrativeArea ?? "Unknown"
            )
            
            cont.resume(returning: country)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let cont = locationContinuation else { return }
        cont.resume(throwing: error)
        cleanup()
    }
}

// MARK: - Error Types

public enum LocationError: LocalizedError {
    /// User denied or app is restricted
    case permissionDenied
    /// Couldn’t map location to a valid country
    case geocodingFailed

    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied"
        case .geocodingFailed:
            return "Failed to determine country from location"
        }
    }
}
