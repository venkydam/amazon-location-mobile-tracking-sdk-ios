import Foundation
import AmazonLocationiOSAuthSDK

public struct GetDevicePositionHistoryResponse: Codable, EncodableRequest {
    public struct DevicePosition: Codable {
        public struct Accuracy: Codable {
            public let horizontal: Double
            
            public init(horizontal: Double) {
                self.horizontal = horizontal
            }
        }

        public let accuracy: Accuracy?
        public let deviceId: String
        public let position: [Double]
        public let positionProperties: [String: String]
        public let receivedTime: String
        public let sampleTime: String
        
        public init(
            accuracy: Accuracy?,
            deviceId: String,
            position: [Double],
            positionProperties: [String: String],
            receivedTime: String,
            sampleTime: String
        ) {
            self.accuracy = accuracy
            self.deviceId = deviceId
            self.position = position
            self.positionProperties = positionProperties
            self.receivedTime = receivedTime
            self.sampleTime = sampleTime
        }
    }

    public let devicePositions: [DevicePosition]
    public let nextToken: String?
    
    public init(devicePositions: [DevicePosition], nextToken: String? = nil) {
        self.devicePositions = devicePositions
        self.nextToken = nextToken
    }

    public func toData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try encoder.encode(self)
    }
}
