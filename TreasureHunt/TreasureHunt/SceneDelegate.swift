import UIKit
import CoreLocation

// SceneDelegate class responsible for managing the app's scenes
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // Property to hold the window instance
    var window: UIWindow?
    
    // Array to store treasures
    var treasures = [Treasure]()
    
    // Called when the scene is about to be connected to the app
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Load treasures from persistent storage
        loadTreasures()
        // Ensure the scene is a UIWindowScene instance
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    // Called when the scene will resign active state
    func sceneWillResignActive(_ scene: UIScene) {
        // Save treasures to persistent storage
        saveTreasures()
    }

    // Called when the scene enters the background
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save treasures to persistent storage
        saveTreasures()
    }
    
    // Function to save treasures to persistent storage
    func saveTreasures() {
        let encoder = JSONEncoder()
        // Encode the treasures array to JSON data
        if let encoded = try? encoder.encode(treasures) {
            // Store the encoded data in UserDefaults
            UserDefaults.standard.set(encoded, forKey: "treasures")
        }
    }
    
    // Function to load treasures from persistent storage
    func loadTreasures() {
        // Retrieve the encoded treasures data from UserDefaults
        if let savedTreasures = UserDefaults.standard.object(forKey: "treasures") as? Data {
            let decoder = JSONDecoder()
            // Decode the data back to an array of Treasure objects
            if let loadedTreasures = try? decoder.decode([Treasure].self, from: savedTreasures) {
                treasures = loadedTreasures
            }
        } else {
            // Load default treasures if none are saved
            treasures = [
                Treasure(name: "Case of Money", coordinate: CLLocationCoordinate2D(latitude: 43.68974781, longitude: -79.33157735)),
                Treasure(name: "Chest of Golden Coins", coordinate: CLLocationCoordinate2D(latitude: 43.8710043, longitude: -79.4455212)),
                Treasure(name: "Bag of Diamonds", coordinate: CLLocationCoordinate2D(latitude: 43.7794015, longitude: -79.651635))
            ]
        }
    }
}
