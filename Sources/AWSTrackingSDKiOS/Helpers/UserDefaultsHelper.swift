import Foundation

enum UserDefaultKeyType: String {
    case AWSAuthApiKey
    case DeviceID
    case TrackingLogs
    case LocaionTrackerConfig
    case LastLocationEntity
}

final class UserDefaultsHelper {
    static func save<T>(value:T , key: UserDefaultKeyType){
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static func saveObject<T: Encodable>(value:T , key: UserDefaultKeyType){
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(value)
            UserDefaults.standard.set(data, forKey: key.rawValue)
            UserDefaults.standard.synchronize()
        } catch {
            print(StringConstants.errorUserDefaultsSave + " \(T.self)")
        }
    }
    
    static func get<T>(for type:T.Type,key: UserDefaultKeyType) -> T? {
        
        if let value = UserDefaults.standard.value(forKey: key.rawValue) as? T {
            return value
        }
        return nil
    }
    
    static func getObject<T: Decodable>(value:T.Type , key: UserDefaultKeyType) -> T?{
        let decoder = JSONDecoder()
        do {
            if let value = UserDefaults.standard.value(forKey: key.rawValue) as? Data {
                let data = try decoder.decode(T.self, from: value)
                return data
            }
            return nil
            
        } catch {
            print(StringConstants.errorUserDefaultsSave +  " \(T.self)")
            return nil
        }
    }
    
    static func removeObject(for key: UserDefaultKeyType) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
}
