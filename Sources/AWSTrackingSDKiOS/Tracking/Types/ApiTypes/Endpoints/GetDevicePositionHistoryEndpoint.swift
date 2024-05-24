import Foundation
import AmazonLocationiOSAuthSDK

public struct GetDevicePositionHistoryEndpoint: AmazonLocationEndpoint {
    public let region: String
    public let trackerName: String
    
    public init(region: String, trackerName: String) {
        self.region = region
        self.trackerName = trackerName
    }
    
    public func url() -> String {
        return "https://tracker.geo.\(region).amazonaws.com/\(trackerName)"
    }
}
