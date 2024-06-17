import Foundation
import AmazonLocationiOSAuthSDK
import CoreLocation
import AWSLocation

internal class LocationUploadSerializer{
    private var deviceId: String
    private var trackerName: String
    private var client: AmazonLocationClient
    
    init(client: AmazonLocationClient, deviceId: String, trackerName: String) {
        self.deviceId = deviceId
        self.trackerName = trackerName
        self.client = client
    }
    
    func updateDeviceLocation(locations: [LocationEntity]) async throws -> BatchUpdateDevicePositionOutput? {
        var positions: [LocationClientTypes.DevicePositionUpdate] = []
        
        for location in locations {
            let positionUpdate = LocationClientTypes.DevicePositionUpdate(accuracy: .init(horizontal: location.accuracy), deviceId: deviceId, position: [location.longitude, location.latitude], positionProperties: [:], sampleTime: Date())
            positions.append(positionUpdate)
        }

        let input = BatchUpdateDevicePositionInput(trackerName: trackerName, updates: positions)
        let result = try await client.batchUpdateDevicePosition(input: input)
        
        return result
    }
    
    func getDeviceLocation(nextToken: String? = nil, startTime: Date? = nil, endTime: Date? = nil, maxResults: Int? = nil) async throws -> GetDevicePositionHistoryOutput? {
        let request = GetDevicePositionHistoryInput(deviceId: deviceId, endTimeExclusive: endTime, maxResults: maxResults, nextToken: nextToken, startTimeInclusive: startTime, trackerName: trackerName)
        let result = try await client.getDevicePositionHistory(input: request)
        return result
    }
    
    func batchEvaluateGeofences(input: BatchEvaluateGeofencesInput) async throws -> BatchEvaluateGeofencesOutput? {
        return try await client.batchEvaluateGeofences(input: input)
    }
}
