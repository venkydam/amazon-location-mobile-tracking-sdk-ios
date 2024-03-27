import CoreLocation
import UIKit

public enum BackgroundTrackingMode: String {
    case Active
    case BatterySaving
    case None
}

public class LocationPermissionManager: NSObject, CLLocationManagerDelegate {
    internal let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
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
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            requestAlwaysPermission()
            break
        case .restricted, .denied:
            break
        case .authorizedWhenInUse:
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
}
