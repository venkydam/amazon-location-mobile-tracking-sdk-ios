import XCTest
import CoreLocation
@testable import AmazonLocationiOSTrackingSDK
import AmazonLocationiOSAuthSDK
import AWSLocationXCF

final class LocationTrackingTests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func readTestConfig() -> [String: String] {
        // Implement reading from your chosen config file. This is an example for a plist.
        guard let plistURL = Bundle.module.url(forResource: "TestConfig", withExtension: "plist"),
              let plistData = try? Data(contentsOf: plistURL) else {
            fatalError("Test configuration file not found.")
        }
        do {
            if let plistDict = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: String] {
                return plistDict
            }
        } catch {
            XCTFail("Error reading plist: \(error)")
        }
        return [:]
    }
    
    func testSetDeviceIDNoID() throws {
        DeviceIdProvider.clearDeviceID()
        DeviceIdProvider.setDeviceID()
        
        XCTAssertNotNil(DeviceIdProvider.getDeviceID())
    }
    
    func testSetDeviceIDWithID() throws {
        let deviceID = UUID().uuidString
        DeviceIdProvider.clearDeviceID()
        DeviceIdProvider.setDeviceID(deviceID: deviceID)
        
        XCTAssertEqual(deviceID, DeviceIdProvider.getDeviceID())
    }
    
    func testSaveLocationToDisk() throws {
        let locationDatabase = LocationDatabase()
        let location = CLLocation(latitude: 49.246559, longitude: -123.063554)
        let locationEntity = locationDatabase.save(location: location)
        XCTAssertEqual(location.coordinate.latitude, locationEntity?.latitude, "Location Entity is saved")
        
        let locations = locationDatabase.fetchAll()
        XCTAssertGreaterThanOrEqual(locations.count, 1, "Location Entity is saved")
        locationDatabase.delete(locationID: locations.first!.id!.uuidString)
    }
    
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
//    
//    func testLocationTrackerInitialization() {
//        let config = readTestConfig()
//        
//        let identityPoolID = config["identityPoolID"]!
//        let trackerName = config["trackerName"]!
//        let authHelper = AuthHelper()
//        let authProvider = authHelper.authenticateWithCognitoUserPool(identityPoolId: identityPoolID)
//
//        let locationTracker = LocationTracker(provider: authProvider, trackerName: trackerName)
//
//        XCTAssertNotNil(locationTracker, "Tracker should be successfully initialized")
//        XCTAssertGreaterThanOrEqual(locationTracker.getTrackerConfig().trackingTimeInterval, 30, "Tracker time interval ")
//        XCTAssertNotNil(locationTracker.getDeviceId(), "Tracker device Id")
//        XCTAssertNotNil(Logger.getLoggerKey())
//    }
//    
//    func testLocationStartTracking() throws {
//        let expectation = self.expectation(description: "Tracking location completes")
//        
//        let config = readTestConfig()
//        
//        let identityPoolID = config["identityPoolID"]!
//        let trackerName = config["trackerName"]!
//        let authHelper = AuthHelper()
//        let authProvider = authHelper.authenticateWithCognitoUserPool(identityPoolId: identityPoolID)
//        
//        let locationTracker = LocationTracker(provider: authProvider, trackerName: trackerName)
//
//        try locationTracker.startTracking()
//        XCTAssertEqual(locationTracker.isTrackingActive, true, "Tracking has started")
//        
//        let location = CLLocation(latitude: 49.2471, longitude: -123.063554)
//        
//        locationTracker.trackLocation(location: location) { success, error in
//            locationTracker.stopTracking()
//            XCTAssertEqual(locationTracker.isTrackingActive, false, "Tracking has stopped")
//            XCTAssertNotNil(locationTracker.getDeviceLocation(), "Tracking has last location")
//            if success {
//                expectation.fulfill()
//            }
//        }
//        
//        waitForExpectations(timeout: 60, handler: nil)
//        
//        try locationTracker.resumeTracking()
//        XCTAssertEqual(locationTracker.isTrackingActive, true, "Tracking has resumed")
//        locationTracker.stopTracking()
//        XCTAssertEqual(locationTracker.isTrackingActive, false, "Tracking has stopped")
//    }
//    
//    func testLocationStartBackgroundTracking() throws {
//        let expectation = self.expectation(description: "Tracking location completes")
//        
//        let config = readTestConfig()
//        
//        let identityPoolID = config["identityPoolID"]!
//        let trackerName = config["trackerName"]!
//        let authHelper = AuthHelper()
//        let authProvider = authHelper.authenticateWithCognitoUserPool(identityPoolId: identityPoolID)
//        
//        let locationTracker = LocationTracker(provider: authProvider, trackerName: trackerName)
//        try locationTracker.startBackgroundTracking(mode: .None)
//        XCTAssertEqual(locationTracker.isTrackingActive, true, "Tracking has started")
//        
//        let location = CLLocation(latitude: 49.2471, longitude: -123.063554)
//        
//        locationTracker.trackLocation(location: location) { success, error in
//            locationTracker.stopBackgroundTracking()
//            XCTAssertEqual(locationTracker.isTrackingActive, false, "Tracking has stopped")
//            if success {
//                expectation.fulfill()
//            }
//        }
//        waitForExpectations(timeout: 60, handler: nil)
//        
//        try locationTracker.resumeBackgroundTracking(mode: .None)
//        XCTAssertEqual(locationTracker.isTrackingActive, true, "Tracking has resumed")
//        locationTracker.stopBackgroundTracking()
//        XCTAssertEqual(locationTracker.isTrackingActive, false, "Tracking has stopped")
//    }
//    
//    func testLocationTrackingConfig() throws {
//        let config = readTestConfig()
//        
//        let identityPoolID = config["identityPoolID"]!
//        let trackerName = config["trackerName"]!
//        let authHelper = AuthHelper()
//        let authProvider = authHelper.authenticateWithCognitoUserPool(identityPoolId: identityPoolID)
//        
//        let locationTracker = LocationTracker(provider: authProvider, trackerName: trackerName)
//        let trackerConfig = LocationTrackerConfig(locationFilters: [TimeLocationFilter(), DistanceLocationFilter(), AccuracyLocationFilter()], trackingDistanceInterval: 30, trackingTimeInterval: 30, trackingAccuracyLevel: 1, uploadFrequency: 60, desiredAccuracy: kCLLocationAccuracyBest, activityType: CLActivityType.fitness, logLevel: .debug)
//        locationTracker.setTrackerConfig(config: trackerConfig)
//        let trackerConfig1 = locationTracker.getTrackerConfig()
//        XCTAssertEqual(trackerConfig.trackingTimeInterval, trackerConfig1.trackingTimeInterval, "Location tracker config set successfully")
//    }
//    
//    func testUserDefaultsHelper() {
//        UserDefaultsHelper.removeObject(for: .DeviceID)
//      XCTAssertNil(UserDefaultsHelper.getObject(value: String.self, key: .DeviceID), "Device ID is nil")
//    }
//    
//    func testLocationTrackingConfigDefault() throws {
//        let config = readTestConfig()
//        
//        let identityPoolID = config["identityPoolID"]!
//        let trackerName = config["trackerName"]!
//        let authHelper = AuthHelper()
//        let authProvider = authHelper.authenticateWithCognitoUserPool(identityPoolId: identityPoolID)
//        
//        let locationTracker = LocationTracker(provider: authProvider, trackerName: trackerName)
//        let trackerConfig = LocationTrackerConfig()
//        locationTracker.setTrackerConfig(config: trackerConfig)
//        let trackerConfig1 = locationTracker.getTrackerConfig()
//        XCTAssertEqual(trackerConfig.trackingTimeInterval, trackerConfig1.trackingTimeInterval, "Location tracker config set successfully")
//    }
//    
//    
//    func testTimeFilter() throws {
//        let locationDatabase = LocationDatabase()
//        let filter = TimeLocationFilter()
//        let config = readTestConfig()
//        
//        let identityPoolID = config["identityPoolID"]!
//        let trackerName = config["trackerName"]!
//        let authHelper = AuthHelper()
//        let authProvider = authHelper.authenticateWithCognitoUserPool(identityPoolId: identityPoolID)
//        
//        let locationTracker = LocationTracker(provider: authProvider, trackerName: trackerName)
//        var location = CLLocation(latitude: 49.246559, longitude: -123.063554)
//        let currentLocationEntity = locationDatabase.save(location: location)
//        currentLocationEntity?.timestamp = Date()
//        
//        location = CLLocation(latitude: 49.246559, longitude: -123.063554)
//        let previousLocationEntity = locationDatabase.save(location: location)
//        previousLocationEntity?.timestamp = Calendar.current.date(byAdding: .minute, value: -2, to: Date())
//        
//        let shouldUpload = filter.shouldUpload(currentLocation: currentLocationEntity!, previousLocation: previousLocationEntity!, trackerConfig: locationTracker.getTrackerConfig())
//        
//        XCTAssertEqual(shouldUpload, true, "TimeFilter location should upload")
//    }
//    
//    func testDistanceFilter() throws {
//        let locationDatabase = LocationDatabase()
//        let filter = DistanceLocationFilter()
//        let config = readTestConfig()
//        
//        let identityPoolID = config["identityPoolID"]!
//        let trackerName = config["trackerName"]!
//        let authHelper = AuthHelper()
//        let authProvider = authHelper.authenticateWithCognitoUserPool(identityPoolId: identityPoolID)
//        
//        let locationTracker = LocationTracker(provider: authProvider, trackerName: trackerName)
//        var location = CLLocation(latitude: 49.2471, longitude: -123.063554)
//        let currentLocationEntity = locationDatabase.save(location: location)
//        currentLocationEntity?.timestamp = Date()
//        
//        location = CLLocation(latitude: 49.246559, longitude: -123.063554)
//        let previousLocationEntity = locationDatabase.save(location: location)
//        previousLocationEntity?.timestamp = Calendar.current.date(byAdding: .minute, value: -2, to: Date())
//        
//        let shouldUpload = filter.shouldUpload(currentLocation: currentLocationEntity!, previousLocation: previousLocationEntity!, trackerConfig: locationTracker.getTrackerConfig())
//        
//        XCTAssertEqual(shouldUpload, true, "DistanceFilter location should upload")
//    }
//    
//    func testAccuracyFilter() throws {
//        let locationDatabase = LocationDatabase()
//        let filter = AccuracyLocationFilter()
//        let config = readTestConfig()
//        
//        let identityPoolID = config["identityPoolID"]!
//        let trackerName = config["trackerName"]!
//        let authHelper = AuthHelper()
//        let authProvider = authHelper.authenticateWithCognitoUserPool(identityPoolId: identityPoolID)
//        
//        let locationTracker = LocationTracker(provider: authProvider, trackerName: trackerName)
//        var location = CLLocation(latitude: 49.2471, longitude: -123.063554)
//        let currentLocationEntity = locationDatabase.save(location: location)
//        currentLocationEntity?.timestamp = Date()
//        
//        location = CLLocation(latitude: 49.246559, longitude: -123.063554)
//        let previousLocationEntity = locationDatabase.save(location: location)
//        previousLocationEntity?.timestamp = Calendar.current.date(byAdding: .minute, value: -2, to: Date())
//        
//        let shouldUpload = filter.shouldUpload(currentLocation: currentLocationEntity!, previousLocation: previousLocationEntity!, trackerConfig: locationTracker.getTrackerConfig())
//        
//        XCTAssertEqual(shouldUpload, true, "AccuracyFilter location should upload")
//    }
//    
//    func testArrayChunk() {
//        let chunks = Utils.chunked(Array(0...99), size: 10)
//        
//        XCTAssertEqual(chunks.count, 10, "Chunk value is 10")
//    }
//    
//    func testGetTrackingLocations() throws {
//        let expectation = self.expectation(description: "Tracking get locations completed")
//        
//        let config = readTestConfig()
//        let identityPoolId = config["identityPoolID"]!
//        let deviceId = config["deviceID"]!
//        let trackerName = config["trackerName"]!
//        let cognitoProvider = AuthHelper().authenticateWithCognitoUserPool(identityPoolId: identityPoolId)
//        let tracker = LocationTracker(provider: cognitoProvider, trackerName: trackerName)
//        let startTime: Date = Date().addingTimeInterval(-86400)
//        let endTime: Date = Date()
//        tracker.getTrackerDeviceLocation(nextToken: nil, startTime: startTime, endTime: endTime, completion: { result in
//            switch result {
//            case .success:
//                    expectation.fulfill()
//            case .failure(let error):
//                XCTFail("Failed to get device tracking history: \(error)")
//            }
//        })
//        
//        waitForExpectations(timeout: 60, handler: nil)
//    }
//    
//    func testRemoveAllHistory() throws {
//        let expectation = self.expectation(description: "Tracking history remove all completed")
//        
//        let config = readTestConfig()
//        let identityPoolId = config["identityPoolID"]!
//        let deviceId = config["deviceID"]!
//        let trackerName = config["trackerName"]!
//        let cognitoProvider = AuthHelper().authenticateWithCognitoUserPool(identityPoolId: identityPoolId)
//        let tracker = LocationTracker(provider: cognitoProvider, trackerName: trackerName)
//        let cognitoUploadSerializer  = CognitoLocationUploadSerializer(client: tracker.amazonLocationClient!, deviceId: deviceId, trackerName: trackerName)
//        cognitoUploadSerializer.removeAllHistory(completion: { result in
//            switch result {
//            case .success:
//                    expectation.fulfill()
//            case .failure(let error):
//                XCTFail("Failed to remove device tracking history: \(error)")
//            }
//        })
//        
//        waitForExpectations(timeout: 60, handler: nil)
//    }
//    
//    func testLocationManager() {
//        let locationManager = LocationPermissionManager()
//        locationManager.setBackgroundMode(mode: .None)
//        
//        XCTAssertEqual(locationManager.hasLocationPermission(), false)
//        XCTAssertEqual(locationManager.hasAlwaysLocationPermission(), false)
//        XCTAssertEqual(locationManager.hasLocationPermissionDenied(), false)
//        XCTAssertEqual(locationManager.checkPermission() , .notDetermined)
//    }
//    
//    func testGetLocationResponse() {
//        let response = AWSLocationGetDevicePositionHistoryResponse()
//        let devicePosition = AWSLocationDevicePosition()
//        devicePosition?.deviceId = UUID().uuidString
//        devicePosition?.position = [49.246559, -123.063554]
//        devicePosition?.receivedTime = Date()
//        devicePosition?.sampleTime = Date()
//        response?.devicePositions = [devicePosition!]
//        let getLocationResponse = GetLocationResponse(awsResponse: response!)
//        XCTAssertEqual(getLocationResponse.devicePositions?.count, 1, "getLocationResponse has count")
//    }
    
    func testBatchUpdateDevicePosition() async throws {
        let config = readTestConfig()
        let identityPoolId = config["identityPoolID"]!
        let region = config["region"]!
        let trackerName = config["trackerName"]!
        
        let authHelper = AuthHelper()
        _ = try? await authHelper.authenticateWithCognitoIdentityPool(identityPoolId: identityPoolId, region: region)
        
        let amazonClient = authHelper.getLocationClient()
        
        let positionAccuracy = PositionAccuracy(horizontal: 5.0)
        let update = Update(
            positionAccuracy: positionAccuracy,
            deviceId: "device123",
            position: [49.246559, -123.063554],
            positionProperties: ["Property1": "Value1", "Property2": "Value2"],
            sampleTime: getCurrentDate()
        )
        let batchUpdateRequest = BatchUpdateDevicePositionRequest(updates: [update])
        
        let positionUpdateResponse = try? await amazonClient!.batchUpdateDevicePosition(trackerName: trackerName, request: batchUpdateRequest)
        
        XCTAssertEqual(positionUpdateResponse?.statusCode, 200, "Device Position updated successfully")
    }
    
    private func getCurrentDate() -> String {
        // Get the current date and time
        let currentDate = Date()

        // Create a date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure UTC time zone
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure fixed date format

        // Format the date to the desired string
        let formattedDateString = dateFormatter.string(from: currentDate)

        return formattedDateString
    }
}
