import MapKit

// Struct to represent a Treasure, conforming to Codable for encoding and decoding
struct Treasure: Codable {
    // Properties for the name and coordinate of the treasure
    let name: String
    let coordinate: CLLocationCoordinate2D
    
    // Enum to specify custom coding keys
    enum CodingKeys: String, CodingKey {
        case name
        case latitude
        case longitude
    }
    
    // Initializer to create a Treasure instance with a name and coordinate
    init(name: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.coordinate = coordinate
    }
    
    // Initializer to decode a Treasure instance from a decoder
    init(from decoder: Decoder) throws {
        // Container to hold the key-value pairs from the decoder
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode the name from the container
        name = try container.decode(String.self, forKey: .name)
        // Decode the latitude and longitude from the container
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        // Create the coordinate using the decoded latitude and longitude
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // Function to encode a Treasure instance to an encoder
    func encode(to encoder: Encoder) throws {
        // Container to hold the key-value pairs for the encoder
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Encode the name to the container
        try container.encode(name, forKey: .name)
        // Encode the latitude and longitude to the container
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
}
