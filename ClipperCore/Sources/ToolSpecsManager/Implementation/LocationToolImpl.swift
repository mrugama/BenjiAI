import Foundation
import CoreLocation

// MARK: - Location Tool Implementation

final class LocationToolImpl: NSObject, LocationTool, CLLocationManagerDelegate, @unchecked Sendable {
    let id: String = "location"
    let name: String = "Location"
    let toolDescription: String = "Get current location, geocode addresses, and calculate distances"
    let category: ToolCategory = .location
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    var specification: ToolSpecification {
        ToolSpecification(
            name: "location",
            description: "Access location services - get current location, geocode addresses, and calculate distances",
            parameters: ToolParameters(
                properties: [
                    "action": ToolParameterProperty(
                        type: "string",
                        description: "The action to perform",
                        enumValues: ["getCurrentLocation", "geocode", "calculateDistance"]
                    ),
                    "address": ToolParameterProperty(
                        type: "string",
                        description: "Address to geocode"
                    ),
                    "fromAddress": ToolParameterProperty(
                        type: "string",
                        description: "Starting address for distance calculation"
                    ),
                    "toAddress": ToolParameterProperty(
                        type: "string",
                        description: "Destination address for distance calculation"
                    )
                ],
                required: ["action"]
            )
        )
    }
    
    func execute(parameters: [String: Any]) async throws -> ToolFunctionResult {
        guard let action = parameters["action"] as? String else {
            throw ToolError.missingParameter("action")
        }
        
        switch action {
        case "getCurrentLocation":
            return try await getCurrentLocation()
            
        case "geocode":
            guard let address = parameters["address"] as? String else {
                throw ToolError.missingParameter("address")
            }
            return try await geocodeAddress(address: address)
            
        case "calculateDistance":
            guard let fromAddress = parameters["fromAddress"] as? String ?? parameters["from"] as? String else {
                throw ToolError.missingParameter("fromAddress")
            }
            guard let toAddress = parameters["toAddress"] as? String ?? parameters["to"] as? String else {
                throw ToolError.missingParameter("toAddress")
            }
            return try await calculateDistance(from: fromAddress, to: toAddress)
            
        default:
            throw ToolError.invalidParameter("action", reason: "Unknown action: \(action)")
        }
    }
    
    func getCurrentLocation() async throws -> ToolFunctionResult {
        let authorized = await requestLocationAccess()
        guard authorized else {
            return .failure(error: "Location access denied")
        }
        
        do {
            let location = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CLLocation, Error>) in
                self.locationContinuation = continuation
                self.locationManager.requestLocation()
            }
            
            // Reverse geocode to get address
            let placemarks = try? await geocoder.reverseGeocodeLocation(location)
            let placemark = placemarks?.first
            
            let addressComponents = [
                placemark?.thoroughfare,
                placemark?.locality,
                placemark?.administrativeArea,
                placemark?.country
            ].compactMap { $0 }
            
            let viewData = ToolViewData(
                type: "current_location",
                data: [
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude,
                    "altitude": location.altitude,
                    "accuracy": location.horizontalAccuracy,
                    "address": addressComponents.joined(separator: ", "),
                    "street": placemark?.thoroughfare ?? "",
                    "city": placemark?.locality ?? "",
                    "state": placemark?.administrativeArea ?? "",
                    "country": placemark?.country ?? "",
                    "postalCode": placemark?.postalCode ?? "",
                    "timestamp": formatDate(location.timestamp)
                ],
                template: "location_display"
            )
            
            return .success(viewData: viewData, metadata: [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ])
        } catch {
            return .failure(error: "Failed to get location: \(error.localizedDescription)")
        }
    }
    
    func geocodeAddress(address: String) async throws -> ToolFunctionResult {
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            
            guard let placemark = placemarks.first, let location = placemark.location else {
                return .failure(error: "Address not found: \(address)")
            }
            
            let formattedAddress = [
                placemark.thoroughfare,
                placemark.locality,
                placemark.administrativeArea,
                placemark.postalCode,
                placemark.country
            ].compactMap { $0 }.joined(separator: ", ")
            
            let viewData = ToolViewData(
                type: "geocoded_location",
                data: [
                    "inputAddress": address,
                    "formattedAddress": formattedAddress,
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude,
                    "street": placemark.thoroughfare ?? "",
                    "city": placemark.locality ?? "",
                    "state": placemark.administrativeArea ?? "",
                    "country": placemark.country ?? "",
                    "postalCode": placemark.postalCode ?? ""
                ],
                template: "geocode_result_display"
            )
            
            return .success(viewData: viewData, metadata: [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ])
        } catch {
            return .failure(error: "Geocoding failed: \(error.localizedDescription)")
        }
    }
    
    func calculateDistance(from: String, to: String) async throws -> ToolFunctionResult {
        do {
            // Geocode both addresses
            async let fromPlacemarks = geocoder.geocodeAddressString(from)
            
            // Need to create a new geocoder for concurrent requests
            let toGeocoder = CLGeocoder()
            async let toPlacemarks = toGeocoder.geocodeAddressString(to)
            
            let (fromResults, toResults) = try await (fromPlacemarks, toPlacemarks)
            
            guard let fromLocation = fromResults.first?.location else {
                return .failure(error: "Could not find location for: \(from)")
            }
            
            guard let toLocation = toResults.first?.location else {
                return .failure(error: "Could not find location for: \(to)")
            }
            
            let distanceMeters = fromLocation.distance(from: toLocation)
            let distanceKm = distanceMeters / 1000
            let distanceMiles = distanceMeters / 1609.344
            
            let viewData = ToolViewData(
                type: "distance_calculation",
                data: [
                    "fromAddress": from,
                    "toAddress": to,
                    "fromLatitude": fromLocation.coordinate.latitude,
                    "fromLongitude": fromLocation.coordinate.longitude,
                    "toLatitude": toLocation.coordinate.latitude,
                    "toLongitude": toLocation.coordinate.longitude,
                    "distanceMeters": distanceMeters,
                    "distanceKilometers": round(distanceKm * 100) / 100,
                    "distanceMiles": round(distanceMiles * 100) / 100,
                    "distanceFormatted": formatDistance(distanceMeters)
                ],
                template: "distance_result_display"
            )
            
            return .success(viewData: viewData, metadata: [
                "distanceMeters": distanceMeters,
                "distanceKilometers": distanceKm,
                "distanceMiles": distanceMiles
            ])
        } catch {
            return .failure(error: "Distance calculation failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationContinuation?.resume(returning: location)
            locationContinuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
    
    // MARK: - Private Helpers
    
    private func requestLocationAccess() async -> Bool {
        let status = locationManager.authorizationStatus
        
        switch status {
        #if os(iOS)
        case .authorizedWhenInUse:
            return true
        #endif
        case .authorizedAlways:
            return true
        case .notDetermined:
            #if os(iOS)
            locationManager.requestWhenInUseAuthorization()
            #elseif os(macOS)
            locationManager.requestAlwaysAuthorization()
            #endif
            // Wait a bit for the user to respond
            try? await Task.sleep(for: .seconds(0.5))
            let newStatus = locationManager.authorizationStatus
            #if os(iOS)
            return newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways
            #else
            return newStatus == .authorizedAlways
            #endif
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatDistance(_ meters: Double) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .naturalScale
        let measurement = Measurement(value: meters, unit: UnitLength.meters)
        return formatter.string(from: measurement)
    }
}
