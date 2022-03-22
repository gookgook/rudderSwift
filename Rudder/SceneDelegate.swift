//
//  SceneDelegate.swift
//  Rudder
//
//  Created by Brian Bae on 13/07/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate{

    var window: UIWindow?
    
    var navigationController = UINavigationController()
    var myNavigationController = UINavigationController()
    var messageNavigationController = UINavigationController()
    var notificationController = UINavigationController()
    let tabBarController = UITabBarController()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        tabBarController.delegate = self
        
        
        
        guard let winScene = (scene as? UIWindowScene) else { return }
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let TmpVC = storyboard.instantiateViewController(identifier: "TmpViewController") as? TmpViewController else {
                    print("Something wrong in storyboard")
                    return
                }
        guard let LoginVC = storyboard.instantiateViewController(identifier: "LoginViewController") as? LoginViewController else {
            print("Something wrong in storyboard")
            return
        }
        
        guard let MyVC = storyboard.instantiateViewController(identifier: "MyPageViewController") as? MyPageViewController else {
            print("Something wrong in storyboard")
            return
        }
        
        guard let MessageVC = storyboard.instantiateViewController(identifier: "MessageViewController") as? MessageRoomViewController else {
            print("Something wrong in storyboard")
            return
        }
        
        guard let NotificationVC = storyboard.instantiateViewController(identifier: "NotificationViewController") as? NotificationViewController else {
            print("Something wrong in storyboard")
            return
        }
        
        if UserDefaults.standard.string(forKey: "token") != nil{
            print("token already exists")
            //navigationController = UINavigationController(rootViewController: LoginVC)
            Utils.firstScreen = 1
            navigationController.pushViewController(TmpVC, animated: true)
            navigationController.viewControllers.insert(LoginVC, at: 0)
            
        }else{
            Utils.firstScreen = 0
            navigationController = UINavigationController(rootViewController: LoginVC)
        }
        
        myNavigationController = UINavigationController(rootViewController: MyVC)
        messageNavigationController = UINavigationController(rootViewController: MessageVC)
        notificationController = UINavigationController(rootViewController: NotificationVC)
        
        tabBarController.tabBar.tintColor = MyColor.rudderPurple
        let naviTabBarItem = UITabBarItem(title: nil, image: UIImage(named: "board"), tag: 0)
        let myPageTabBarItem = UITabBarItem(title: nil, image: UIImage(named: "myPage"), tag: 1)
        let messageTabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "envelope"), tag: 2)
        let notificationTabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "bell"), tag: 3)
        //tag와 tab bar 순서 안맞는 사소한 문제
        navigationController.tabBarItem = naviTabBarItem
        myNavigationController.tabBarItem = myPageTabBarItem
        messageNavigationController.tabBarItem = messageTabBarItem
        notificationController.tabBarItem = notificationTabBarItem
        
        
        let controllers = [navigationController, messageNavigationController,  myNavigationController,notificationController]
        tabBarController.setViewControllers(controllers, animated: true)
        //tabBarController.tabBar.selectedImageTintColor = UIColor(red: 147/255, green: 41/255, blue: 209/255, alpha: 1)
        window = UIWindow(windowScene: winScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        let k_moveToNotification = Notification.Name("moveToNotification") //이거이름재설정 필요
        NotificationCenter.default.addObserver(self, selector: #selector(self.moveTab(notification:)), name: k_moveToNotification, object: nil)
        
        //let k_moveToNotification = Notification.Name("moveToNotification")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

//tab bar double tap 방지
extension SceneDelegate: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return viewController != tabBarController.selectedViewController
    }
    
    @objc func moveTab(notification: NSNotification){
        self.tabBarController.selectedIndex = 3
    }
}
