public class TimeLocationFilter: LocationFilter {
    
    public init() {
    }
    
    public func shouldUpload(currentLocation: LocationEntity, previousLocation: LocationEntity?, trackerConfig: LocationTrackerConfig) -> Bool {
        if (currentLocation.timestamp == nil || previousLocation == nil  || previousLocation?.timestamp == nil) {
            return true
        }
        let durationInSeconds = currentLocation.timestamp!.timeIntervalSince(previousLocation!.timestamp!)
        let shouldUpload = durationInSeconds > trackerConfig.trackingTimeInterval
        return shouldUpload
    }
}
