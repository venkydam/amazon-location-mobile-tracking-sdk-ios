import CoreLocation

public typealias Callback = (CLLocation) -> Void

internal class LocationProvider: NSObject, CLLocationManagerDelegate {
    
    public var locationPermissionManager: LocationPermissionManager?
    internal let locationManager: CLLocationManager = CLLocationManager()
    
    public var lastKnownLocation: LocationEntity?
    
    private var locationUpdateListener: Callback?
    
    public override init() {
        super.init()
        self.locationPermissionManager = LocationPermissionManager(locationManager: self.locationManager)
        self.locationManager.delegate = self
    }
    
    public func setFilterValues(trackingDistanceInterval: Double, desiredAccuracy: CLLocationAccuracy, activityType: Int) {
        locationManager.distanceFilter = CLLocationDistance(floatLiteral: trackingDistanceInterval)
        locationManager.desiredAccuracy =  desiredAccuracy
        locationManager.activityType = CLActivityType(rawValue: activityType) ?? .fitness
    }
    
    public func subscribeToLocationUpdates(listener: @escaping Callback) {
        locationUpdateListener = listener
        locationManager.startUpdatingLocation()
    }
    
    public func unsubscribeToLocationUpdates() {
        locationUpdateListener = nil
        locationManager.stopUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationUpdateListener?(location)
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .restricted, .denied:
            break
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(CLLocationManager.authorizationStatus())
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print(region.identifier)
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: any Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error)
    }
}
