//
//  SceneDelegate.swift
//  SeatGeek
//
//  Created by Sagar Tilekar on 27/10/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = makeRootViewController()
        window?.makeKeyAndVisible()
    }

    func makeRootViewController() -> UIViewController {
        let urlSession = URLSession.shared
        let client = HTTPClient(session: urlSession)
        let viewModel = EventViewModel(client: client)
        let viewController = ViewController()
        viewController.viewModel = viewModel
        viewController.imageLoader = ImageLoader(session: urlSession)
        return UINavigationController(rootViewController: viewController)
    }
}

