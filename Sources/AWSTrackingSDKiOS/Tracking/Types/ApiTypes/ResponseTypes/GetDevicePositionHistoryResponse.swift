import Foundation
import AmazonLocationiOSAuthSDK

public struct GetDevicePositionHistoryResponse: Codable, EncodableRequest {
    public struct DevicePosition: Codable {
        public struct Accuracy: Codable {
            public let Horizontal: Double
            
            public init(Horizontal: Double) {
                self.Horizontal = Horizontal
            }
        }

        public let Accuracy: Accuracy?
        public let DeviceId: String
        public let Position: [Double]
        public let PositionProperties: [String: String]
        public let ReceivedTime: String
        public let SampleTime: String
        
        public init(
            Accuracy: Accuracy?,
            DeviceId: String,
            Position: [Double],
            PositionProperties: [String: String],
            ReceivedTime: String,
            SampleTime: String
        ) {
            self.Accuracy = Accuracy
            self.DeviceId = DeviceId
            self.Position = Position
            self.PositionProperties = PositionProperties
            self.ReceivedTime = ReceivedTime
            self.SampleTime = SampleTime
        }
    }

    public let DevicePositions: [DevicePosition]
    public let NextToken: String?
    
    public init(DevicePositions: [DevicePosition], NextToken: String? = nil) {
        self.DevicePositions = DevicePositions
        self.NextToken = NextToken
    }

    public func toData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
}
