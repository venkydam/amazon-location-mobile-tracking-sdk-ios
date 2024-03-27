import Combine
import Foundation

public enum LogLevel: Codable {
  case  none, debug, error
    
}

internal class Logger: ObservableObject {
    static let shared = Logger()
    
    var formatter: DateFormatter
    public var logLevel: LogLevel
    
    public static func getLoggerKey() -> String {
        return UserDefaultKeyType.TrackingLogs.rawValue
    }
    
    private init() {
        UserDefaultsHelper.removeObject(for: .TrackingLogs)
        formatter = DateFormatter()
        formatter.dateFormat = "dd-MM HH:mm:ss"
        self.logLevel = .debug
    }

    public var logs: String = ""
    
    public func log(_ message: String) {
        if(logLevel != .none) {
            print(message)
        }
        if(logLevel == .debug) {
            logs = "\(formatter.string(from: Date())): \(message)\n" + logs // prepend new log to logs variable
            UserDefaultsHelper.save(value: logs, key: .TrackingLogs)
        }
    }
}
