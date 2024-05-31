import Foundation
import AmazonLocationiOSAuthSDK
import AWSLocation
import AWSClientRuntime

public extension AmazonLocationClient {
    
    func batchUpdateDevicePosition(input: BatchUpdateDevicePositionInput) async throws -> BatchUpdateDevicePositionOutput? {
        do {
            if locationProvider.getCognitoProvider() != nil {
                if locationClient == nil {
                    try await initialiseLocationClient()
                }
                let response = try await locationClient!.batchUpdateDevicePosition(input: input)
                return response
            }
        }
        catch {
            throw error
        }
        return nil
    }
    
    func getDevicePositionHistory(input: GetDevicePositionHistoryInput) async throws -> GetDevicePositionHistoryOutput? {
        do {
            if locationProvider.getCognitoProvider() != nil {
                if locationClient == nil {
                    try await initialiseLocationClient()
                }
                let response = try await locationClient!.getDevicePositionHistory(input: input)
                return response
            }
        }
        catch {
            throw error
        }
        return nil
    }
    
    func batchEvaluateGeofences(input: BatchEvaluateGeofencesInput) async throws -> BatchEvaluateGeofencesOutput? {
        do {
            if locationProvider.getCognitoProvider() != nil {
                if locationClient == nil {
                    try await initialiseLocationClient()
                }
                let response = try await locationClient!.batchEvaluateGeofences(input: input)
                return response
            }
        }
        catch {
            throw error
        }
        return nil
    }
}
