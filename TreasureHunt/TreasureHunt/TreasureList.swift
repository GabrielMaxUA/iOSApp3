import UIKit
import MapKit
import CoreLocation

// Table view controller class responsible for displaying and managing a list of treasures
class TreasureList: UITableViewController, CLLocationManagerDelegate {
    
    // CLLocationManager instance to handle location updates
    let locationManager = CLLocationManager()
    
    // Computed property to get and set treasures from the SceneDelegate
    var treasures: [Treasure] {
        get {
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
            return sceneDelegate.treasures
        }
        set {
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
            sceneDelegate.treasures = newValue
            tableView.reloadData()
        }
    }
    
    // Property to store the index of the selected treasure
    var selectedTreasureIndex: Int?

    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the location manager's delegate to self
        locationManager.delegate = self
        // Request location authorization
        locationManager.requestWhenInUseAuthorization()
        
        // Register a cell class for the table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TreasureCell")
        
        // Create an add button and set its action to open the map view
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openMapView))
        navigationItem.rightBarButtonItem = addButton
    }
    
    // Function to open the map view
    @objc func openMapView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    // MARK: - Table view data source
    
    // Function to return the number of rows in the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return treasures.count
    }
    
    // Function to configure the cell for a given row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TreasureCell", for: indexPath)
        let treasure = treasures[indexPath.row]
        cell.textLabel?.text = treasure.name
        return cell
    }
    
    // MARK: - Table view delegate
    
    // Function called when a row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTreasureIndex = indexPath.row
        checkLocationAuthorization()
    }
    
    // Function to check location authorization status
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showLocationDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        @unknown default:
            fatalError("Unhandled case in location authorization status")
        }
    }
    
    // CLLocationManagerDelegate function called when location updates are available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let selectedTreasureIndex = selectedTreasureIndex {
            let treasureLocation = CLLocation(latitude: treasures[selectedTreasureIndex].coordinate.latitude, longitude: treasures[selectedTreasureIndex].coordinate.longitude)
            let userLocation = locations.last!
            let distance = userLocation.distance(from: treasureLocation)
            let thresholdDistance: CLLocationDistance = 50.0
            
            if distance < thresholdDistance {
                let foundTreasureName = treasures[selectedTreasureIndex].name
                treasures.remove(at: selectedTreasureIndex)
                tableView.reloadData()
                let alert = UIAlertController(title: "Treasure Found!", message: "You have found the \(foundTreasureName). It has been removed from the list.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                openMap(for: selectedTreasureIndex)
            }
        }
    }
    
    // CLLocationManagerDelegate function called when location updates fail
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
    
    // CLLocationManagerDelegate function called when authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    // Function to open the map for a specific treasure
    func openMap(for treasureIndex: Int) {
        let treasure = treasures[treasureIndex]
        let coordinate = treasure.coordinate
        let regionDistance: CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = treasure.name
        mapItem.openInMaps(launchOptions: options)
    }
    
    // Function to show an alert if location access is denied
    func showLocationDeniedAlert() {
        let alert = UIAlertController(title: "Location Access Denied", message: "Location access is required to find the treasures. Please enable location services in settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Function to add a new treasure to the list
    func addNewTreasure(treasure: Treasure) {
        treasures.append(treasure)
        tableView.reloadData()
    }
}
