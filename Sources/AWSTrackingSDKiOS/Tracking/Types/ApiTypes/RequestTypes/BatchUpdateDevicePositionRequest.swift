import Foundation
import AmazonLocationiOSAuthSDK

public struct BatchUpdateDevicePositionRequest: Codable, EncodableRequest {
    public let updates: [Update]
    
    enum CodingKeys: String, CodingKey {
        case updates = "Updates"
    }

    public func toData() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}

public struct Update: Codable {
    public let positionAccuracy: PositionAccuracy
    public let deviceId: String
    public let position: [Double]
    public let positionProperties: [String: String]
    public let sampleTime: String
    
    enum CodingKeys: String, CodingKey {
        case positionAccuracy = "Accuracy"
        case deviceId = "DeviceId"
        case position = "Position"
        case positionProperties = "PositionProperties"
        case sampleTime = "SampleTime"
    }
}

// Define a struct for the PositionAccuracy field
public struct PositionAccuracy: Codable {
    public let horizontal: Double
    
    enum CodingKeys: String, CodingKey {
        case horizontal = "Horizontal"
    }
}
