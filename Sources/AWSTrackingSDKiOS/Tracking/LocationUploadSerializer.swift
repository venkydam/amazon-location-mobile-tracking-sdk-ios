import Foundation
import AmazonLocationiOSAuthSDK
import CoreLocation
import AWSLocation

internal class LocationUploadSerializer{
    private var deviceId: String
    private var trackerName: String
    private var client: LocationClient
    
    init(client: LocationClient, deviceId: String, trackerName: String) {
        self.deviceId = deviceId
        self.trackerName = trackerName
        self.client = client
    }
    
    func updateDeviceLocation(locations: [LocationEntity]) async throws -> BatchUpdateDevicePositionOutput {
        var deviceUpdates: [LocationClientTypes.DevicePositionUpdate] = []
        for location in locations {
            let accuracy = LocationClientTypes.PositionalAccuracy(horizontal: location.accuracy)
            let update: LocationClientTypes.DevicePositionUpdate = LocationClientTypes.DevicePositionUpdate(accuracy: accuracy, deviceId: deviceId, position: [location.longitude, location.latitude], positionProperties: [:], sampleTime: Date())
            deviceUpdates.append(update)
        }

        let input = AWSLocation.BatchUpdateDevicePositionInput(
            trackerName: trackerName,
            updates: deviceUpdates
        )
        let result = try await self.client.batchUpdateDevicePosition(input: input)
        
        return result
    }
    
    func getDeviceLocation(nextToken: String? = nil, startTime: Date? = nil, endTime: Date? = nil, maxResults: Int? = nil) async throws -> GetDevicePositionHistoryOutput {
        let input = GetDevicePositionHistoryInput(
            deviceId: deviceId,
            endTimeExclusive: endTime,
            maxResults: maxResults,
            nextToken: nextToken,
            startTimeInclusive: startTime,
            trackerName: trackerName
        )
        let result = try await self.client.getDevicePositionHistory(input: input)
        return result
    }
    
    func batchEvaluateGeofences(input: BatchEvaluateGeofencesInput) async throws -> BatchEvaluateGeofencesOutput {
        return try await self.client.batchEvaluateGeofences(input: input)
    }
}
