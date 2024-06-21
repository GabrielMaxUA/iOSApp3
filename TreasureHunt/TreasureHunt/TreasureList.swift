import UIKit
import MapKit
import CoreLocation

class TreasureList: UITableViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    // Array of tuples containing the names and coordinates of the treasures
    let treasures = [
           ("Case of Money", CLLocationCoordinate2D(latitude: 43.72539, longitude: -79.436669)),
           ("Chest of Golden Coins", CLLocationCoordinate2D(latitude: 43.8710043, longitude: -79.4455212)),
           ("Bag of Diamonds", CLLocationCoordinate2D(latitude: 43.7794015, longitude: -79.651635))
       ]
    
    // Variable to keep track of the selected treasure index
    var selectedTreasureIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegate for the location manager to the current view controller
        locationManager.delegate = self
        
        // Request the user's permission to use location services when the app is in use
        locationManager.requestWhenInUseAuthorization()
        
        // Register the UITableViewCell class with the identifier "TreasureCell"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TreasureCell")
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return treasures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell with the identifier "TreasureCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "TreasureCell", for: indexPath)
        
        // Get the treasure name for the current row
        let treasure = treasures[indexPath.row]
        
        // Set the cell's text label to the treasure name
        cell.textLabel?.text = treasure.0
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Store the selected treasure index
        selectedTreasureIndex = indexPath.row
        
        // Check location authorization and proceed to open the map for the selected treasure
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        
        switch locationManager.authorizationStatus {
        case .notDetermined:// Request location authorization if the status is not determined
            
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // Show an alert if the location access is restricted or denied
            print("Location access restricted or denied")
            showLocationDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            // Request the current location if the permission is already granted
            print("Location authorized, requesting location")
//            locationManager.requestLocation()
                openMap(for: selectedTreasureIndex!)
        @unknown default:
            // Handle any unknown cases
            fatalError("Unhandled case in location authorization status")
        }
    }
    
    // CLLocationManagerDelegate method to handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let selectedTreasureIndex = selectedTreasureIndex {
            openMap(for: selectedTreasureIndex)
        }
    }
    
    // CLLocationManagerDelegate method to handle location update failures
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
    
    // CLLocationManagerDelegate method to handle changes in authorization status
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Location authorization status changed to: \(manager.authorizationStatus.rawValue)")
        
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            // Request the current location if the permission is already granted
            print("Location authorization granted, requesting location")
            locationManager.requestLocation()
        }
    }
    
    func openMap(for treasureIndex: Int) {
        print("Opening map for treasure at index: \(treasureIndex)")
        
        // Get the selected treasure's name and coordinates
        let treasure = treasures[treasureIndex]
        let coordinate = treasure.1
        
        // Define the region distance and span for the map
        let regionDistance: CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        
        // Define options for launching the map
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        
        // Create a placemark and map item for the selected treasure
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = treasure.0
        
        // Open the map with the defined options
        print("Map item: \(mapItem)")
        mapItem.openInMaps(launchOptions: options)
    }
    
    func showLocationDeniedAlert() {
        let alert = UIAlertController(title: "Location Access Denied", message: "Location access is required to find the treasures. Please enable location services in settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
