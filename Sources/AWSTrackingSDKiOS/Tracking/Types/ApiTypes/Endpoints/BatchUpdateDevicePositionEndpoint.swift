import Foundation
import AmazonLocationiOSAuthSDK

public struct BatchUpdateDevicePositionEndpoint: AmazonLocationEndpoint {
    public let region: String
    public let trackerName: String
    
    public init(region: String, trackerName: String) {
        self.region = region
        self.trackerName = trackerName
    }
    
    public func url() -> String {
        return "https://tracking.geo.\(region).amazonaws.com/tracking/v0/trackers/\(trackerName)/positions"
    }
}
