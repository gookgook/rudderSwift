//
//  AppDelegate.swift
//  Rudder
//
//  Created by Brian Bae on 13/07/2021.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        ImageCache.imageCache.removeAllObjects()
        
        let center = UNUserNotificationCenter.current()
        
        center.delegate = self
        
        let notificationCenter = UNUserNotificationCenter.current()
                
                notificationCenter.getNotificationSettings
                { (settings) in
                    // Do not schedule notifications if not authorized.
                    let center = UNUserNotificationCenter.current()
                    // Request permission to display alerts and play sounds.
                    center.requestAuthorization(options: [.alert, .sound])
                    { (granted, error) in
                        guard granted else { //User didn't agree
                            print("User didn't allow push alarm")
                            return
                        }
                        // User agreed
                        print("User allowed push alarm")
                        // 메인 쓰레드 UI와 Thread 동기화 처리 될 수 있도록, DispatchQueue.main.async 메소드로 감싸 줍니다.
                        DispatchQueue.main.async {
                            // APNs 에 스마트폰을 등록하는 메소드 입니다. (네트워크)
                            UIApplication.shared.registerForRemoteNotifications()
                            
                        }
                    }
                }
        return true
    }
    
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("pushpush touched when background")
        NotificationViewController.notiRefresh = true
        let k_moveToNotification = Notification.Name("moveToNotification") //이거이름재설정 필요
        NotificationCenter.default.post(name: k_moveToNotification, object: nil, userInfo: nil)
        //self.tabBarController?.selectedIndex = 0
    }
    
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void){
        print("pushpush touched when foreground")
        //let k_moveToNotification = Notification.Name("moveToNotification") //이거이름재설정 필요
        //NotificationCenter.default.post(name: k_moveToNotification, object: nil, userInfo: nil)
        //self.tabBarController?.selectedIndex = 0
    }
    

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken
        deviceToken: Data) {

        // 토큰 값을 가지고 옵니다.
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})

        // 콘솔에 토큰 값을 표시해 줍니다.
        UserDefaults.standard.set(deviceTokenString, forKey: "ApnToken")
        print("APNs device token: \(deviceTokenString)")

    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError
        error: Error) {

        // Try again later.
        print("APN register error : "+error.localizedDescription)

    }
    
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

