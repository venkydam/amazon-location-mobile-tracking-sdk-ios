import Foundation
import CoreLocation
import AmazonLocationiOSAuthSDK

public class LocationTracker {
    
    internal var locationProvider: LocationProvider
    private var cognitoLocationUploadSerializer: CognitoLocationUploadSerializer?
    internal var amazonLocationClient: AmazonLocationClient?
    private var locationDatabase: LocationDatabase
    internal var isTrackingActive: Bool = false
    private var logger: Logger
    private var config: LocationTrackerConfig
    private var trackerName: String

    public init(provider: LocationCredentialsProvider, trackerName: String, config: LocationTrackerConfig? = nil) {
        self.trackerName = trackerName

        logger = Logger.shared
        locationDatabase = LocationDatabase()
        locationProvider = LocationProvider()
        
        self.config = config ?? LocationTrackerConfig.getTrackerConfig() ?? LocationTrackerConfig()
        LocationTrackerConfig.saveTrackerConfig(locationTrackerConfig: self.config)
        locationProvider.setFilterValues(trackingDistanceInterval: self.config.trackingDistanceInterval, desiredAccuracy: self.config.desiredAccuracy, activityType: self.config.activityType)
        
        var deviceId: String
        if let id = DeviceIdProvider.getDeviceID() {
            deviceId = id
        }
        else {
            DeviceIdProvider.setDeviceID()
            deviceId = DeviceIdProvider.getDeviceID()!
        }
        
        if provider.getCognitoProvider() != nil {
            amazonLocationClient = AmazonLocationClient(locationCredentialsProvider: provider)
            cognitoLocationUploadSerializer = CognitoLocationUploadSerializer(client: amazonLocationClient!, deviceId: deviceId, trackerName: self.trackerName)
        }
        
        logger.log("Location Tracker intialized")
    }
    
    public func setTrackerConfig(config: LocationTrackerConfig) {
        self.config = config
        let containsDistanceLocationFilter = self.config.locationFilters.contains { $0 is DistanceLocationFilter }
        
        let containsAccuracyLocationFilter = self.config.locationFilters.contains { $0 is AccuracyLocationFilter }
        
        LocationTrackerConfig.saveTrackerConfig(locationTrackerConfig: config)
        
        locationProvider.setFilterValues(
            trackingDistanceInterval: containsDistanceLocationFilter ? self.config.trackingDistanceInterval: Constants.FilterDistanceInterval,
            desiredAccuracy: containsAccuracyLocationFilter ? self.config.trackingAccuracyLevel: Constants.FilterAccuracyInterval,
            activityType: self.config.activityType)
    }
    
    public func getTrackerConfig() -> LocationTrackerConfig {
        return config
    }
    
    public func getDeviceId() -> String? {
        return DeviceIdProvider.getDeviceID()
    }
    
    
    public func startTracking() throws {
        guard let locationPermissionManager = locationProvider.locationPermissionManager else {
              return
        }

        if locationPermissionManager.hasLocationPermissionDenied() {
            throw TrackingLocationError.permissionDenied
        }
        
        locationProvider.locationPermissionManager?.setBackgroundMode(mode: .None)
        
        locationProvider.subscribeToLocationUpdates { location in
            Task {
                do {
                    _ = try await self.trackLocation(location: location)
                }
                catch {
                    print(error)
                }
            }
        }
        isTrackingActive = true
    }
    
    public func resumeTracking() throws {
        try startTracking()
    }
    
    public func stopTracking() {
        locationProvider.unsubscribeToLocationUpdates()
        isTrackingActive = false
    }
    
    public func startBackgroundTracking(mode: BackgroundTrackingMode) throws {
        
        guard let locationPermissionManager = locationProvider.locationPermissionManager else {
              return
        }

        if locationPermissionManager.hasLocationPermissionDenied() {
            throw TrackingLocationError.permissionDenied
        }
        
        if !locationProvider.locationPermissionManager!.hasAlwaysLocationPermission() {
            locationProvider.locationPermissionManager?.requestAlwaysPermission()
        }
        
        locationProvider.locationPermissionManager?.setBackgroundMode(mode: mode)
        
        if !isTrackingActive {
            locationProvider.subscribeToLocationUpdates { location in
                Task {
                    do {
                        _ = try await self.trackLocation(location: location)
                    }
                    catch {
                        print(error)
                    }
                }
            }
            isTrackingActive = true
        }
    }
    
    public func resumeBackgroundTracking(mode: BackgroundTrackingMode) throws {
        try startBackgroundTracking(mode: mode)
    }
    
    public func stopBackgroundTracking() {
        locationProvider.locationPermissionManager?.setBackgroundMode(mode: .None)
        locationProvider.unsubscribeToLocationUpdates()
        isTrackingActive = false
    }
    
    public func getTrackerDeviceLocation(nextToken: String?, startTime: Date? = nil, endTime: Date? = nil) async throws -> GetDevicePositionHistoryResponse? {
        if cognitoLocationUploadSerializer != nil {
           return try await getTrackerDeviceLocations(with: cognitoLocationUploadSerializer!, nextToken: nil)
        }
        return nil
    }
    
    public func getDeviceLocation() -> LocationEntity? {
        return locationProvider.lastKnownLocation
    }
    
    private func updateTrackerDeviceLocation(retries: Int = 3) async throws ->  EmptyResponse? {
        let locations = locationDatabase.fetchAll()
        let filteredLocations = filterLocations(locations: locations)
        let chunks = Utils.chunked(filteredLocations, size: 10)
        return try await sendChunkedLocations(locations: chunks, retries: retries)
    }
    
    internal func trackLocation(location: CLLocation) async throws -> EmptyResponse? {
        if(!isTrackingActive) {
            return nil
        }
        logger.log("Updated location: \(location.coordinate.latitude), \(location.coordinate.longitude) horizontalAccuracy: \(location.horizontalAccuracy)")
        return try await setLastKnownLocation(location: location)
    }
    
    private func setLastKnownLocation(location: CLLocation) async throws -> EmptyResponse? {
        locationProvider.lastKnownLocation = getLastLocationEntity()
        let _ = saveLocationToDisk(location: location)
        
        let response = try await updateTrackerDeviceLocation()
        if response != nil && (200...299).contains(response!.statusCode) {
            print("Successfully updated all tracker device location.")
        }
        else if response != nil {
            print("Failed to update tracker device location: \(response!.statusCode): \(response!.description)")
        }
        return response
    }
    
    private func getLastLocationEntity() -> LocationEntity? {
        let locationEx = UserDefaultsHelper.getObject(value: LocationEx.self, key: .LastLocationEntity)
        if locationEx != nil {
            let context = CoreDataStack.shared.persistentContainer.viewContext
            let newLocationEntity = LocationEntity(context: context)
            newLocationEntity.id = UUID(uuidString: locationEx!.id!)
            newLocationEntity.longitude = locationEx!.longitude
            newLocationEntity.latitude = locationEx!.latitude
            newLocationEntity.timestamp = locationEx!.timestamp
            newLocationEntity.accuracy = locationEx!.accuracy
            return newLocationEntity
        }
        return nil
    }
    
    private func saveLastLocationEntity(locationEntity: LocationEntity?) {
        var locationEx: LocationEx?
        if locationEntity != nil {
            locationEx = LocationEx(id: locationEntity!.id?.uuidString, longitude: locationEntity!.longitude, latitude: locationEntity!.latitude, timestamp: locationEntity!.timestamp, accuracy: locationEntity!.accuracy)
            UserDefaultsHelper.saveObject(value: locationEx, key: .LastLocationEntity)
        }
    }

    private func getTrackerDeviceLocations<S: LocationUploadSerializer>(with serializer: S, nextToken: String?, startTime: Date? = nil, endTime: Date? = nil)  async throws -> GetDevicePositionHistoryResponse {
        return try await serializer.getDeviceLocation(nextToken: nextToken, startTime: startTime, endTime: endTime, maxResults: nil)
    }
    
    private func filterLocations(locations: [LocationEntity]) -> [LocationEntity] {
        var filteredLocations: [LocationEntity] = []
        var previousLocation: LocationEntity? = getLastLocationEntity()

        for location in locations {
            var shouldSkip = false
            for filter in config.locationFilters {
                if !filter.shouldUpload(currentLocation: location, previousLocation: previousLocation, trackerConfig: config) {
                    locationDatabase.delete(locations: [location])
                    shouldSkip = true
                    break
                }
            }
            if !shouldSkip {
                filteredLocations.append(location)
                previousLocation = location
                locationProvider.lastKnownLocation = location
                saveLastLocationEntity(locationEntity: location)
            }
        }
        
        return filteredLocations
    }
    
    private func sendChunkedLocations(locations: [[LocationEntity]], retries: Int) async throws -> EmptyResponse? {
        guard !locations.isEmpty else {
            self.logger.log("All locations uploaded successfully")
            return nil
        }
        
        let chunk = locations.first!
        
        if cognitoLocationUploadSerializer != nil {
            return try await updateLocations(with: cognitoLocationUploadSerializer!, locations: locations, chunk: chunk, retries: retries)
        }
        return nil
    }
    
    private func updateLocations<S: LocationUploadSerializer>(with serializer: S, locations: [[LocationEntity]], chunk: [LocationEntity], retries: Int) async throws -> EmptyResponse? {
        let response = try await serializer.updateDeviceLocation(locations: chunk)
        if (200...299).contains(response.statusCode) {
            self.logger.log("\(chunk.count) Tracking locations uploaded successfully")
            self.locationDatabase.delete(locations: chunk)
            return try await sendChunkedLocations(locations: Array(locations.dropFirst()), retries: 3)
        }
        else {
            self.logger.log("Error: \(response.description)")
            if retries > 0 {
                self.logger.log("Retrying...")
                return try await sendChunkedLocations(locations: locations, retries: retries - 1)
            } else {
                self.logger.log("Failed after 3 retries")
                throw NSError() //Error(response.description)
            }
        }
    }
    
    private func saveLocationToDisk(location: CLLocation) -> LocationEntity? {
        return locationDatabase.save(location: location)
    }
}
