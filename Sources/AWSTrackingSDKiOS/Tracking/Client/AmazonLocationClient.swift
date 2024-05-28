import Foundation
import AmazonLocationiOSAuthSDK

public extension AmazonLocationClient {
    
    func batchUpdateDevicePosition(trackerName: String, request: BatchUpdateDevicePositionRequest) async throws -> AmazonLocationResponse<EmptyData, BatchUpdateDevicePositionErrorsResponse> {
        
        let result: AmazonLocationResponse<EmptyData, BatchUpdateDevicePositionErrorsResponse> = try await sendRequest(
            serviceName: .Location,
            endpoint: BatchUpdateDevicePositionEndpoint(region: locationProvider.getRegion()!, trackerName: trackerName),
            httpMethod: .POST,
            requestBody: request,
            successType: EmptyData.self,
            errorType: BatchUpdateDevicePositionErrorsResponse.self
        )
        
        return result
    }
    
    
    func getDevicePositionHistory(trackerName: String, deviceId: String, request: GetDevicePositionHistoryRequest) async throws -> AmazonLocationResponse<GetDevicePositionHistoryResponse, AmazonErrorResponse> {
        
        let result: AmazonLocationResponse<GetDevicePositionHistoryResponse, AmazonErrorResponse> = try await sendRequest(
            serviceName: .Location,
            endpoint: GetDevicePositionHistoryEndpoint(region: locationProvider.getRegion()!, trackerName: trackerName, deviceId: deviceId),
            httpMethod: .POST,
            requestBody: request,
            successType: GetDevicePositionHistoryResponse.self,
            errorType: AmazonErrorResponse.self
        )
        
        return result
    }
}
