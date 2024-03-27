import CoreLocation

public class DistanceLocationFilter: LocationFilter {
    
    public init() {
    }
    
    public func shouldUpload(currentLocation: LocationEntity, previousLocation: LocationEntity?, trackerConfig: LocationTrackerConfig) -> Bool {
        if (previousLocation == nil || previousLocation?.id == nil) {
            return true
        }
        let currentLocationCoordinates = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let previousLocationCoordinates = CLLocation(latitude: previousLocation!.latitude, longitude: previousLocation!.longitude)

        let distanceInMeters = currentLocationCoordinates.distance(from: previousLocationCoordinates)
        let shouldUpload = distanceInMeters >= trackerConfig.trackingDistanceInterval
        return shouldUpload
    }
}
