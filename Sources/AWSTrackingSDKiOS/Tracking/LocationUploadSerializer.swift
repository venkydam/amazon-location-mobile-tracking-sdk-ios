import Foundation
import AmazonLocationiOSAuthSDK
import CoreLocation

internal class LocationUploadSerializer{
    private var deviceId: String
    private var trackerName: String
    private var client: AmazonLocationClient
    
    init(client: AmazonLocationClient, deviceId: String, trackerName: String) {
        self.deviceId = deviceId
        self.trackerName = trackerName
        self.client = client
    }
    
    func updateDeviceLocation(locations: [LocationEntity]) async throws -> AmazonLocationResponse<EmptyData, BatchUpdateDevicePositionErrorsResponse> {
        
        var positions: [Update] = []
        
        for location in locations {
            let positionUpdate = Update(positionAccuracy: .init(horizontal: location.accuracy), deviceId: deviceId, position: [location.longitude, location.latitude], positionProperties: [:], sampleTime: Utils.jsonDateToString(date: Date()))
            positions.append(positionUpdate)
        }

        let request = BatchUpdateDevicePositionRequest(updates: positions)
        let result = try await client.batchUpdateDevicePosition(trackerName: trackerName, request: request)
        
        return result
    }
    
    func getDeviceLocation(nextToken: String? = nil, startTime: Date? = nil, endTime: Date? = nil, maxResults: Int? = nil) async throws -> AmazonLocationResponse<GetDevicePositionHistoryResponse, AmazonErrorResponse> {
        let startTimeInclusive = startTime != nil ? Utils.jsonDateToString(date: startTime!) : nil
        let endTimeInclusive = endTime != nil ? Utils.jsonDateToString(date: endTime!) : nil
        let request = GetDevicePositionHistoryRequest(startTimeInclusive: startTimeInclusive, endTimeExclusive: endTimeInclusive, maxResults: maxResults, nextToken: nextToken)
        
        let result = try await client.getDevicePositionHistory(trackerName: trackerName, deviceId: deviceId, request: request)
        return result
    }
}
