import Foundation

internal class LocationEx: Codable {
    var id: String?
    var longitude: Double
    var latitude: Double
    var timestamp: Date?
    var accuracy: Double
    
    init(id: String? = nil, longitude: Double, latitude: Double, timestamp: Date? = nil, accuracy: Double) {
        self.id = id
        self.longitude = longitude
        self.latitude = latitude
        self.timestamp = timestamp
        self.accuracy = accuracy
    }
}
