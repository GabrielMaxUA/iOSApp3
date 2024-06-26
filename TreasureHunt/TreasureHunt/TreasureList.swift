import UIKit
import MapKit
import CoreLocation

class TreasureList: UITableViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
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
    
    var selectedTreasureIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TreasureCell")
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openMapView))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func openMapView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return treasures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TreasureCell", for: indexPath)
        let treasure = treasures[indexPath.row]
        cell.textLabel?.text = treasure.name
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTreasureIndex = indexPath.row
        checkLocationAuthorization()
    }
    
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
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
    
    func showLocationDeniedAlert() {
        let alert = UIAlertController(title: "Location Access Denied", message: "Location access is required to find the treasures. Please enable location services in settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func addNewTreasure(treasure: Treasure) {
        treasures.append(treasure)
        tableView.reloadData()
    }
}
