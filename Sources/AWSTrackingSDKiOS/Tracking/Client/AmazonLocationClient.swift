import Foundation
import AmazonLocationiOSAuthSDK

public extension AmazonLocationClient {
    
    func batchUpdateDevicePosition(trackerName: String, request: BatchUpdateDevicePositionRequest) async throws -> EmptyResponse {
        
        let result: Result<EmptyResponse, BatchUpdateDevicePositionErrorsResponse> = try await sendRequest(
            serviceName: .Location,
            endpoint: BatchUpdateDevicePositionEndpoint(region: locationProvider.getRegion()!, trackerName: trackerName),
            httpMethod: .POST,
            requestBody: request,
            successType: EmptyResponse.self,
            errorType: BatchUpdateDevicePositionErrorsResponse.self
        )
        
        switch result {
        case .success(let response):
            return response
        case .failure(let errorResponse):
            throw errorResponse
        }
    }
}
