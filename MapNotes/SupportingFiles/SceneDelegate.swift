import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let rootViewController = MapComposer.make(
            input: MapInputContainer(
                locationService: LocationService(),
                placesService: PlacesServiceImpl(),
                flowModel: MapFlowModel(),
                viewModelAdapter: MapAdapterImpl()
            )
        )

        window.rootViewController = UINavigationController(rootViewController: rootViewController)
        window.makeKeyAndVisible()

        self.window = window
    }
}
