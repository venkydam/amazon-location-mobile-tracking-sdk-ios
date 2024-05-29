import CoreLocation

public typealias Callback = (CLLocation) -> Void

internal class LocationProvider: NSObject, CLLocationManagerDelegate {
    
    public var locationPermissionManager: LocationPermissionManager?
    private var locationManager: CLLocationManager?
    
    public var lastKnownLocation: LocationEntity?
    
    private var locationUpdateListener: Callback?
    
    public override init() {
        super.init()
        self.locationPermissionManager = LocationPermissionManager()
        self.locationManager = locationPermissionManager?.locationManager
        self.locationManager?.delegate = self
    }
    
    public func setFilterValues(trackingDistanceInterval: Double, desiredAccuracy: CLLocationAccuracy, activityType: Int) {
        locationManager?.distanceFilter = CLLocationDistance(floatLiteral: trackingDistanceInterval)
        locationManager?.desiredAccuracy =  desiredAccuracy
        locationManager?.activityType = CLActivityType(rawValue: activityType) ?? .fitness
    }
    
    @MainActor public func subscribeToLocationUpdates(listener: @escaping Callback) {
        locationUpdateListener = listener
        locationManager?.startUpdatingLocation()
    }
    
    public func unsubscribeToLocationUpdates() {
        locationUpdateListener = nil
        locationManager?.stopUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationUpdateListener?(location)
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationPermissionManager?.locationManager(manager, didChangeAuthorization: status)
    }
}
