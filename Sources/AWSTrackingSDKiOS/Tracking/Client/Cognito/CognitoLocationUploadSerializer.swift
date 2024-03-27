import Foundation
import AmazonLocationiOSAuthSDK
import CoreLocation
import AWSLocationXCF
import AWSMobileClientXCF

internal class CognitoLocationUploadSerializer: LocationUploadSerializer {
    typealias UpdateLocationResponseType = AWSLocationBatchUpdateDevicePositionResponse
    typealias GetLocationResponseType = GetLocationResponse
    
    private var deviceId: String
    private var trackerName: String
    private var client: AWSLocation
    
    init(client: AWSLocation, deviceId: String, trackerName: String) {
        self.deviceId = deviceId
        self.trackerName = trackerName
        self.client = client
    }
    
    func updateDeviceLocation(locations: [LocationEntity], completion: @escaping  (Result<UpdateLocationResponseType, Error>) -> Void) {
        
        let request = AWSLocationBatchUpdateDevicePositionRequest()!
        request.trackerName = trackerName
        var positions: [AWSLocationDevicePositionUpdate] = []
        
        for location in locations {
            let positionUpdate = AWSLocationDevicePositionUpdate()!
            positionUpdate.deviceId = deviceId
            positionUpdate.position = [NSNumber(value: location.longitude), NSNumber(value: location.latitude)]
            positionUpdate.sampleTime = Date()
            
            positions.append(positionUpdate)
        }
        
        // Add the position updates to the request
        request.updates = positions
        
        let result = client.batchUpdateDevicePosition(request)
        
        result.continueWith { response in
            if let taskResult = response.result {
                completion(.success(taskResult))
            } else {
                let defaultError = NSError(domain: "Tracking", code: -1)
                let error = response.error ?? defaultError
                print("error \(error)")
                completion(.failure(error))
            }

            return nil
        }
    }

    func getDeviceLocation(nextToken: String? = nil, startTime: Date? = nil, endTime: Date? = nil, completion: @escaping  (Result<GetLocationResponseType, Error>) -> Void) {
        let request = AWSLocationGetDevicePositionHistoryRequest()!
        request.trackerName = trackerName
        request.deviceId = deviceId
        if nextToken != nil {
            request.nextToken = nextToken
        }
        if startTime != nil {
            request.startTimeInclusive = startTime
        }
        if endTime != nil {
            request.endTimeExclusive = endTime
        }
        
        let result = client.getDevicePositionHistory(request)
        
        result.continueWith { response in
            if let taskResult = response.result {
                let getLocationReponse = GetLocationResponse(awsResponse: taskResult)
                completion(.success(getLocationReponse))
            } else {
                let defaultError = NSError(domain: "Tracking", code: -1)
                let error = response.error ?? defaultError
                print("error \(error)")
                completion(.failure(error))
            }
            
            return nil
        }
    }
    
    func removeAllHistory(completion: @escaping  (Result<Void, Error>) -> Void) {
        let request = AWSLocationBatchDeleteDevicePositionHistoryRequest()!
        request.trackerName = trackerName
        request.deviceIds = [deviceId]
        
        let result = client.batchDeleteDevicePositionHistory(request)
        
        result.continueWith { response in
            if response.result != nil {
                completion(.success(()))
            } else {
                let defaultError = NSError(domain: "Tracking", code: -1)
                let error = response.error ?? defaultError
                print("error \(error)")
                completion(.failure(error))
            }
            return nil
        }
    }
}

extension GetLocationResponse {
    init(awsResponse: AWSLocationGetDevicePositionHistoryResponse) {
        let devicePositions = awsResponse.devicePositions?.map { awsDevicePosition in
            return DevicePosition(
                accuracy:  awsDevicePosition.accuracy != nil ? Accuracy(horizontal: awsDevicePosition.accuracy?.horizontal as? Double) : nil,
                deviceId: awsDevicePosition.deviceId,
                position: Position(latitude: awsDevicePosition.position?.last?.doubleValue, longitude: awsDevicePosition.position?.first?.doubleValue),
                positionProperties: awsDevicePosition.positionProperties ?? [:],
                receivedTime: awsDevicePosition.receivedTime,
                sampleTime: awsDevicePosition.sampleTime
            )
        }
        
        self.init(
            devicePositions: devicePositions,
            nextToken: awsResponse.nextToken
        )
    }
}
