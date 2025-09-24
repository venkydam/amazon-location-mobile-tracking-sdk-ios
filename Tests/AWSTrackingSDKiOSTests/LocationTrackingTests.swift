import XCTest
import CoreLocation
@testable import AmazonLocationiOSTrackingSDK
import AmazonLocationiOSAuthSDK
import AWSLocation

final class LocationTrackingTests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    // Reads test configuration from environment variables
    func readTestConfig() -> [String: String] {
        let configDict: [String: String] = [
            "region": ProcessInfo.processInfo.environment["REGION"] ?? "",
            "apiKey": ProcessInfo.processInfo.environment["API_KEY"] ?? "",
            "identityPoolID": ProcessInfo.processInfo.environment["IDENTITY_POOL_ID"] ?? "",
            "trackerName": ProcessInfo.processInfo.environment["TRACKER_NAME"] ?? "",
            "deviceID": ProcessInfo.processInfo.environment["DEVICE_ID"] ?? ""
        ]
        let missingKeys = configDict.filter { $0.value.isEmpty }.map { $0.key }
        if !missingKeys.isEmpty {
            XCTFail("Missing required environment variables: \(missingKeys.joined(separator: ", "))")
        }
        
        return configDict
    }
    // Tests device ID generation when no ID is provided
    func testSetDeviceIDNoID() throws {
        DeviceIdProvider.clearDeviceID()
        DeviceIdProvider.setDeviceID()
        
        XCTAssertNotNil(DeviceIdProvider.getDeviceID())
    }

    // Tests device ID setting with a custom ID
    func testSetDeviceIDWithID() throws {
        let deviceID = UUID().uuidString
        DeviceIdProvider.clearDeviceID()
        DeviceIdProvider.setDeviceID(deviceID: deviceID)
        
        XCTAssertEqual(deviceID, DeviceIdProvider.getDeviceID())
    }

     
    // Tests saving location data to local database
    func testSaveLocationToDisk() throws {
        let locationDatabase = LocationDatabase()
        let location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let locationEntity = locationDatabase.save(location: location)
        XCTAssertEqual(location.coordinate.latitude, locationEntity?.latitude, "Location Entity is saved")
        
        let locations = locationDatabase.fetchAll()
        XCTAssertGreaterThanOrEqual(locations.count, 1, "Location Entity is saved")
        locationDatabase.delete(locationID: locations.first!.id!.uuidString)
    }
      
    // Tests deleting location data from local database
        func testDeleteLocationToDisk() throws {
        let locationDatabase = LocationDatabase()
        var location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        var locationEntity = locationDatabase.save(location: location)
        XCTAssertEqual(location.coordinate.latitude, locationEntity?.latitude, "Location Entity is saved")
        
        var locations = locationDatabase.fetchAll()
        XCTAssertGreaterThanOrEqual(locations.count, 1, "Location Entity is saved")
        locationDatabase.delete(locationID: locations.first!.id!.uuidString)
        
        location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        locationEntity = locationDatabase.save(location: location)
        XCTAssertEqual(location.coordinate.latitude, locationEntity?.latitude, "Location Entity is saved")
        
        locations = locationDatabase.fetchAll()
        XCTAssertGreaterThanOrEqual(locations.count, 1, "Location Entity is greater than 1")
        locationDatabase.delete(locations: locations)
        
        locations = locationDatabase.fetchAll()
        XCTAssertGreaterThanOrEqual(locations.count, 0, "Location delete locations is 0")
        
        location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        locationEntity = locationDatabase.save(location: location)
        XCTAssertEqual(location.coordinate.latitude, locationEntity?.latitude, "Location Entity is saved")
        
        locations = locationDatabase.fetchAll()
        XCTAssertGreaterThanOrEqual(locations.count, 1, "Location Entity is greater than 1")
        locationDatabase.deleteAll()

        XCTAssertGreaterThanOrEqual(locationDatabase.count(), 0, "Location delete all result is 0")
    }
      
    // Tests LocationTracker initialization with AWS credentials
    func testLocationTrackerInitialization() async throws {
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)

        XCTAssertNotNil(locationTracker, "Tracker should be successfully initialized")
        XCTAssertGreaterThanOrEqual(locationTracker.getTrackerConfig().trackingTimeInterval, 30, "Tracker time interval ")
        XCTAssertNotNil(locationTracker.getDeviceId(), "Tracker device Id")
        XCTAssertNotNil(Logger.getLoggerKey())
    }
     
    // Tests starting, stopping, and resuming location tracking
    func testLocationStartTracking() async throws {
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)

        try locationTracker.startTracking()
        XCTAssertEqual(locationTracker.isTrackingActive, true, "Tracking has started")
        
        let location = CLLocation(latitude: 49.2471, longitude: -123.063554)
        
        locationTracker.trackLocation(location: location)
        
        locationTracker.stopTracking()
        XCTAssertEqual(locationTracker.isTrackingActive, false, "Tracking has stopped")
        
        try locationTracker.resumeTracking()
        XCTAssertEqual(locationTracker.isTrackingActive, true, "Tracking has resumed")
        locationTracker.stopTracking()
        XCTAssertEqual(locationTracker.isTrackingActive, false, "Tracking has stopped")
    }
      
    // Tests background location tracking functionality
    func testLocationStartBackgroundTracking() async throws {
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)
        try locationTracker.startBackgroundTracking(mode: .None)
        XCTAssertEqual(locationTracker.isTrackingActive, true, "Tracking has started")
        
        let location = CLLocation(latitude: 49.2471, longitude: -123.063554)
        
        locationTracker.trackLocation(location: location)
        
        locationTracker.stopBackgroundTracking()
        XCTAssertEqual(locationTracker.isTrackingActive, false, "Tracking has stopped")
        
        try locationTracker.resumeBackgroundTracking(mode: .None)
        XCTAssertEqual(locationTracker.isTrackingActive, true, "Tracking has resumed")
        locationTracker.stopBackgroundTracking()
        XCTAssertEqual(locationTracker.isTrackingActive, false, "Tracking has stopped")
    }

       
    // Tests setting custom location tracking configuration
    func testLocationTrackingConfig() async throws {
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)
        let trackerConfig = LocationTrackerConfig(locationFilters: [TimeLocationFilter(), DistanceLocationFilter(), AccuracyLocationFilter()], trackingDistanceInterval: 30, trackingTimeInterval: 30, trackingAccuracyLevel: 1, uploadFrequency: 60, desiredAccuracy: kCLLocationAccuracyBest, activityType: CLActivityType.fitness, logLevel: .debug)
        locationTracker.setTrackerConfig(config: trackerConfig)
        let trackerConfig1 = locationTracker.getTrackerConfig()
        XCTAssertEqual(trackerConfig.trackingTimeInterval, trackerConfig1.trackingTimeInterval, "Location tracker config set successfully")
    }

     
    // Tests UserDefaults helper for device ID storage
    func testUserDefaultsHelper() {
        UserDefaultsHelper.removeObject(for: .DeviceID)
      XCTAssertNil(UserDefaultsHelper.getObject(value: String.self, key: .DeviceID), "Device ID is nil")
    }
    
    // Tests default location tracking configuration
    func testLocationTrackingConfigDefault() async throws {
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)
        let trackerConfig = LocationTrackerConfig()
        locationTracker.setTrackerConfig(config: trackerConfig)
        let trackerConfig1 = locationTracker.getTrackerConfig()
        XCTAssertEqual(trackerConfig.trackingTimeInterval, trackerConfig1.trackingTimeInterval, "Location tracker config set successfully")
    }
    
    
    // Tests time-based location filtering
    func testTimeFilter() async throws {
        let locationDatabase = LocationDatabase()
        let filter = TimeLocationFilter()
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)
        var location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let currentLocationEntity = locationDatabase.save(location: location)
        currentLocationEntity?.timestamp = Date()
        
        location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let previousLocationEntity = locationDatabase.save(location: location)
        previousLocationEntity?.timestamp = Calendar.current.date(byAdding: .minute, value: -2, to: Date())
        
        let shouldUpload = filter.shouldUpload(currentLocation: currentLocationEntity!, previousLocation: previousLocationEntity!, trackerConfig: locationTracker.getTrackerConfig())
        
        XCTAssertEqual(shouldUpload, true, "TimeFilter location should upload")
    }
    
    // Tests distance-based location filtering
    func testDistanceFilter() async throws {
        let locationDatabase = LocationDatabase()
        let filter = DistanceLocationFilter()
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)
        var location = CLLocation(latitude: 49.2471, longitude: -123.063554)
        let currentLocationEntity = locationDatabase.save(location: location)
        currentLocationEntity?.timestamp = Date()
        
        location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let previousLocationEntity = locationDatabase.save(location: location)
        previousLocationEntity?.timestamp = Calendar.current.date(byAdding: .minute, value: -2, to: Date())
        
        let shouldUpload = filter.shouldUpload(currentLocation: currentLocationEntity!, previousLocation: previousLocationEntity!, trackerConfig: locationTracker.getTrackerConfig())
        
        XCTAssertEqual(shouldUpload, true, "DistanceFilter location should upload")
    }
    
    // Tests accuracy-based location filtering
    func testAccuracyFilter() async throws {
        let locationDatabase = LocationDatabase()
        let filter = AccuracyLocationFilter()
        let config = readTestConfig()
        
        let identityPoolID = config["identityPoolID"]!
        let trackerName = config["trackerName"]!

        let locationTracker = try await LocationTracker(identityPoolId: identityPoolID, trackerName: trackerName)
        var location = CLLocation(latitude: 49.2471, longitude: -123.063554)
        let currentLocationEntity = locationDatabase.save(location: location)
        currentLocationEntity?.timestamp = Date()
        
        location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let previousLocationEntity = locationDatabase.save(location: location)
        previousLocationEntity?.timestamp = Calendar.current.date(byAdding: .minute, value: -2, to: Date())
        
        let shouldUpload = filter.shouldUpload(currentLocation: currentLocationEntity!, previousLocation: previousLocationEntity!, trackerConfig: locationTracker.getTrackerConfig())
        
        XCTAssertEqual(shouldUpload, true, "AccuracyFilter location should upload")
    }
    
    // Tests retrieving tracked locations from AWS
    func testGetTrackingLocations() async throws {
        let config = readTestConfig()
        let identityPoolId = config["identityPoolID"]!
        let trackerName = config["trackerName"]!
        let tracker = try await LocationTracker(identityPoolId: identityPoolId, trackerName: trackerName)
        let startTime: Date = Date().addingTimeInterval(-86400)
        let endTime: Date = Date()
        let result = try await tracker.getTrackerDeviceLocation(nextToken: nil, startTime: startTime, endTime: endTime)
        
        XCTAssertNotNil(result, "Found device's tracker locations")
    }

    // Tests location manager permission status
    func testLocationManager() {
        let locationProvider = LocationProvider()
        locationProvider.locationPermissionManager!.setBackgroundMode(mode: .None)
        
        XCTAssertEqual(locationProvider.locationPermissionManager!.hasLocationPermission(), false)
        XCTAssertEqual(locationProvider.locationPermissionManager!.hasAlwaysLocationPermission(), false)
        XCTAssertEqual(locationProvider.locationPermissionManager!.hasLocationPermissionDenied(), false)
        XCTAssertEqual(locationProvider.locationPermissionManager!.checkPermission() , .notDetermined)
    }
    
    // Tests setting background mode to None
    func testLocationPermissionManagerSetBackgroundModeNone() {
        let locationManager = CLLocationManager()
        let permissionManager = LocationPermissionManager(locationManager: locationManager)
        
        permissionManager.setBackgroundMode(mode: .None)
        
        XCTAssertFalse(locationManager.allowsBackgroundLocationUpdates)
        XCTAssertFalse(locationManager.pausesLocationUpdatesAutomatically)
    }

    // Tests background tracking mode string descriptions
    func testBackgroundTrackingModeDescription() {
        XCTAssertEqual(BackgroundTrackingMode.Active.description, "Active")
        XCTAssertEqual(BackgroundTrackingMode.BatterySaving.description, "BatterySaving")
        XCTAssertEqual(BackgroundTrackingMode.None.description, "None")
    }

    // Tests location permission request methods
    func testLocationPermissionManagerRequestPermissions() {
        let locationManager = CLLocationManager()
        let permissionManager = LocationPermissionManager(locationManager: locationManager)
        
        // These methods should execute without crashing
        permissionManager.requestPermission()
        permissionManager.requestAlwaysPermission()
        
        XCTAssertNotNil(permissionManager)
    }

    // Tests checking current location permission status
    func testLocationPermissionManagerCheckPermission() {
        let locationManager = CLLocationManager()
        let permissionManager = LocationPermissionManager(locationManager: locationManager)
        
        let status = permissionManager.checkPermission()
        
        XCTAssertNotNil(status)
    }
    
    // Tests LocationProvider initialization
    func testLocationProviderInitialization() {
        let locationProvider = LocationProvider()
        
        XCTAssertNotNil(locationProvider.locationPermissionManager)
        XCTAssertNotNil(locationProvider.locationManager)
        XCTAssertNil(locationProvider.lastKnownLocation)
    }
    
    // Tests LocationProvider error handling
    func testLocationProviderDidFailWithError() {
        let locationProvider = LocationProvider()
        let testError = NSError(domain: "TestError", code: 1, userInfo: nil)
        
        locationProvider.locationManager(locationProvider.locationManager, didFailWithError: testError)
        
        XCTAssertNotNil(locationProvider)
    }

    // Tests LocationProvider region monitoring failure
    func testLocationProviderMonitoringDidFail() {
        let locationProvider = LocationProvider()
        let testRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 49.246559, longitude: -123.063554), radius: 100, identifier: "test")
        let testError = NSError(domain: "TestError", code: 1, userInfo: nil)
        
        locationProvider.locationManager(locationProvider.locationManager, monitoringDidFailFor: testRegion, withError: testError)
        
        XCTAssertNotNil(locationProvider)
    }

}

    
