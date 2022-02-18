//
//  AppDelegate.swift
//  smartapp
//
//  Created by Greg Ellis on 2022-02-10.
//

import UIKit
import JOSESwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    fileprivate func setupNavigationAppearance() {
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.backgroundColor = Theme.colors.navigationBarBackgroundColor()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        else {
            let appearance = UINavigationBar.appearance()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.barTintColor = Theme.colors.navigationBarBackgroundColor()
        }
    }
    
    func setupDatabase(){
        DatabaseManager.shared().checkAndLoadDB(dbFileName: "db.db")
    }
    
    func setupUserDefaults(){
        let userDefaults = UserDefaults.standard
        if let hideDateOfBirth = userDefaults.value(forKey: Constants.SETTINGS_HIDE_DATEOFBIRTH) {
            print("birthdate has a value of \(hideDateOfBirth)")
        }
        else {
            print("date of birth empty")
            userDefaults.set(true, forKey: Constants.SETTINGS_HIDE_DATEOFBIRTH)
            userDefaults.synchronize()
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupNavigationAppearance()
        setupDatabase()
        setupUserDefaults()
        
        return true
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

