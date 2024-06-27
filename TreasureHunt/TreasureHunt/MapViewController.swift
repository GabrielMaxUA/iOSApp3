import UIKit
import MapKit

// ViewController class responsible for managing the map view
class MapViewController: UIViewController, MKMapViewDelegate {

    // Outlet for the MKMapView
    @IBOutlet weak var mapView: MKMapView!

    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show an informational alert
        showAlert()
        // Set the map view's delegate to self
        mapView.delegate = self
        
        // Create a long press gesture recognizer
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        // Add the gesture recognizer to the map view
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    // Function to handle long press gestures
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            // Get the location of the long press in the map view
            let location = gestureRecognizer.location(in: mapView)
            // Convert the location to map coordinates
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            // Add a pin at the specified coordinates
            addPinAtCoordinate(coordinate: coordinate)
        }
    }
    
    // Function to add a pin at a specific coordinate
    func addPinAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        // Set the annotation's coordinate
        annotation.coordinate = coordinate
        // Add the annotation to the map view
        mapView.addAnnotation(annotation)
        
        // Present a dialog to add a new treasure
        presentAddTreasureDialog(coordinate: coordinate)
    }
    
    // Function to present a dialog for adding a new treasure
    func presentAddTreasureDialog(coordinate: CLLocationCoordinate2D) {
        let alert = UIAlertController(title: "New Treasure", message: "Enter a name for the new treasure", preferredStyle: .alert)
        // Add a text field to the alert for the treasure name
        alert.addTextField { textField in
            textField.placeholder = "Treasure Name"
        }
        // Add a cancel action to the alert
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // Add an add action to the alert
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            // Get the treasure name from the text field
            if let treasureName = alert.textFields?.first?.text, !treasureName.isEmpty {
                // Add the new treasure
                self?.addNewTreasure(name: treasureName, coordinate: coordinate)
            }
        }))
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    // Function to add a new treasure
    func addNewTreasure(name: String, coordinate: CLLocationCoordinate2D) {
        let treasure = Treasure(name: name, coordinate: coordinate)
        
        // Notify the main view controller to add the new treasure
        if let navigationController = self.navigationController,
           let treasureListVC = navigationController.viewControllers.first as? TreasureList {
            treasureListVC.addNewTreasure(treasure: treasure)
        }
        
        // Pop the current view controller off the navigation stack
        navigationController?.popViewController(animated: true)
    }
    
    // Function to show an informational alert
    func showAlert() {
        // Create an instance of UIAlertController
        let alertController = UIAlertController(title: "Information", message: "To pin a new treasure location please find the desired location on a map then longpress on it and enter the name of the treasure.", preferredStyle: .alert)
        
        // Add an action (button) to the alert
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
}
