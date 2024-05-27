import Foundation
import AmazonLocationiOSAuthSDK

public struct GetDevicePositionHistoryEndpoint: AmazonLocationEndpoint {
    public let region: String
    public let trackerName: String
    public let deviceId: String
    
    public init(region: String, trackerName: String, deviceId: String) {
        self.region = region
        self.trackerName = trackerName
        self.deviceId = deviceId
    }
    
    public func url() -> String {
        return "https://tracking.geo.\(region).amazonaws.com/tracking/v0/trackers/\(trackerName)/devices/\(deviceId)/list-positions"
    }
}
