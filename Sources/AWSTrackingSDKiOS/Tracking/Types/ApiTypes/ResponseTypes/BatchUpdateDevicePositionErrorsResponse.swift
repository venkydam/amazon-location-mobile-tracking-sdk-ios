import Foundation
import AmazonLocationiOSAuthSDK

public struct BatchUpdateDevicePositionErrorsResponse: AmazonBaseErrorResponse, Error {
    public let errors: [ErrorDetail]
    
    enum CodingKeys: String, CodingKey {
        case errors = "Errors"
    }
    
    public var errorCode: String {
        return errors.first?.error.code ?? "Unknown"
    }
    
    public var errorMessage: String {
        return errors.first?.error.message ?? "Unknown error"
    }
    
    public struct ErrorDetail: Codable {
        public let deviceId: String
        public let error: ErrorInfo
        public let sampleTime: String
        
        enum CodingKeys: String, CodingKey {
            case deviceId = "DeviceId"
            case error = "Error"
            case sampleTime = "SampleTime"
        }
        
        public struct ErrorInfo: Codable {
            public let code: String
            public let message: String
            
            enum CodingKeys: String, CodingKey {
                case code = "Code"
                case message = "Message"
            }
        }
    }
}
