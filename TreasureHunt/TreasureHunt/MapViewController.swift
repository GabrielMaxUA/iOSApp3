import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            addPinAtCoordinate(coordinate: coordinate)
        }
    }
    
    func addPinAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        presentAddTreasureDialog(coordinate: coordinate)
    }
    
    func presentAddTreasureDialog(coordinate: CLLocationCoordinate2D) {
        let alert = UIAlertController(title: "New Treasure", message: "Enter a name for the new treasure", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Treasure Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            if let treasureName = alert.textFields?.first?.text, !treasureName.isEmpty {
                self?.addNewTreasure(name: treasureName, coordinate: coordinate)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func addNewTreasure(name: String, coordinate: CLLocationCoordinate2D) {
        let treasure = Treasure(name: name, coordinate: coordinate)
        
        // Notify the main view controller to add the new treasure
        if let navigationController = self.navigationController,
           let treasureListVC = navigationController.viewControllers.first as? TreasureList {
            treasureListVC.addNewTreasure(treasure: treasure)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
