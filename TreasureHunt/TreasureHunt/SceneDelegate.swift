import UIKit
import CoreLocation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var treasures = [Treasure]()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        loadTreasures()
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        saveTreasures()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        saveTreasures()
    }
    
    func saveTreasures() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(treasures) {
            UserDefaults.standard.set(encoded, forKey: "treasures")
        }
    }
    
    func loadTreasures() {
        if let savedTreasures = UserDefaults.standard.object(forKey: "treasures") as? Data {
            let decoder = JSONDecoder()
            if let loadedTreasures = try? decoder.decode([Treasure].self, from: savedTreasures) {
                treasures = loadedTreasures
            }
       } 
            else {
            // Load default treasures if none are saved
            treasures = [
                Treasure(name: "Case of Money", coordinate: CLLocationCoordinate2D(latitude: 43.68974781, longitude: -79.33157735)),
                Treasure(name: "Chest of Golden Coins", coordinate: CLLocationCoordinate2D(latitude: 43.8710043, longitude: -79.4455212)),
                Treasure(name: "Bag of Diamonds", coordinate: CLLocationCoordinate2D(latitude: 43.7794015, longitude: -79.651635))
            ]
        }
    }
}
