import Foundation
import AmazonLocationiOSAuthSDK

public struct GetDevicePositionHistoryRequest: Codable, EncodableRequest {
    public let endTimeExclusive: String?
    public let maxResults: Int?
    public let nextToken: String?
    public let startTimeInclusive: String?

    public init(startTimeInclusive: String? = nil, endTimeExclusive: String? = nil, maxResults: Int? = nil, nextToken: String? = nil) {
        self.startTimeInclusive = startTimeInclusive
        self.endTimeExclusive = endTimeExclusive
        self.maxResults = maxResults
        self.nextToken = nextToken
    }
    
    public func toData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try encoder.encode(self)
    }
}
