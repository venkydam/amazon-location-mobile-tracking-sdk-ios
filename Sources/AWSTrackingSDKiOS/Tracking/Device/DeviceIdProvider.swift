import Foundation

class DeviceIdProvider {
    
    public static func getDeviceID() -> String? {
        return UserDefaultsHelper.get(for: String.self, key: .DeviceID)
    }
    
    public static func clearDeviceID() {
        UserDefaultsHelper.removeObject(for: .DeviceID)
    }
    
    public static func setDeviceID(deviceID: String? = nil) {
        var id = deviceID
        if id == nil {
            id = UUID().uuidString
        }
        UserDefaultsHelper.save(value: id, key: .DeviceID)
    }
    
    
}
