import Foundation

public struct GetLocationResponse: Decodable {
    public let devicePositions: [DevicePosition]?
    public let nextToken: String?
}

public struct DevicePosition: Decodable {
    public let accuracy: Accuracy?
    public let deviceId: String?
    public let position: Position?
    public let positionProperties: [String: String]?
    public let receivedTime: Date?
    public let sampleTime: Date?
}

public struct Accuracy: Decodable {
    public let horizontal: Double?
}

public struct Position: Decodable {
    public let latitude: Double?
    public let longitude: Double?
}

protocol LocationUploadSerializer {
 
    associatedtype UpdateLocationResponseType
    associatedtype GetLocationResponseType
    
    func updateDeviceLocation(locations: [LocationEntity], completion: @escaping  (Result<UpdateLocationResponseType, Error>) -> Void)
    
    func getDeviceLocation(nextToken: String?, startTime: Date?, endTime: Date?, completion: @escaping  (Result<GetLocationResponseType, Error>) -> Void)
}
