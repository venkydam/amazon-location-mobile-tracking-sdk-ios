import CoreLocation
import UIKit

public enum BackgroundTrackingMode: String {
    case Active
    case BatterySaving
    case None
}

public class LocationPermissionManager {
    internal let locationManager: CLLocationManager
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }
    
    public func setBackgroundMode(mode: BackgroundTrackingMode) {
        switch mode {
        case .Active:
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
        case .BatterySaving:
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        case .None:
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.pausesLocationUpdatesAutomatically = false
        }
    }
    
    public func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func requestAlwaysPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    public func hasLocationPermission() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
    
    public func hasAlwaysLocationPermission() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways:
            return true
        default:
            return false
        }
    }
    
    public func hasLocationPermissionDenied() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .denied:
            return true
        default:
            return false
        }
    }
    
    public func checkPermission() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
}
