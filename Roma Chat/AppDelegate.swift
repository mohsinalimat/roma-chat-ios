//
//  AppDelegate.swift
//  Roma Chat
//
//  Created by Barrett Breshears on 3/8/19.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit
import SafariServices
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SFSafariViewControllerDelegate {

    var window: UIWindow?

    var storyboard = UIStoryboard()
    var landingNavigationController = LandingNavigationController()
    var masterNavigationController = MasterNavigationController()
    
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        return spinner
    }()
    
    lazy var spinnerView: UIView = {
        let spinnerView = UIView(frame: UIScreen.main.bounds)
        spinnerView.backgroundColor = StoreStruct.colorSpinnerBackground
        spinnerView.addSubview(spinner)
        return spinnerView
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        storyboard = UIStoryboard(name: "Main", bundle: nil)
        landingNavigationController = storyboard.instantiateViewController(withIdentifier: Storyboard.landingNavigationController) as! LandingNavigationController
        
        self.window?.rootViewController = landingNavigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.host == "success" {
            let x = url.absoluteString
            let y = x.split(separator: "=")
            StoreStruct.shared.currentInstance.authCode = y[1].description
            
            if let safariVC = self.window?.rootViewController?.presentedViewController as? SFSafariViewController {
                safariVC.dismiss(animated: true, completion: {
                    self.fetchAccessTokenAndProceed()
                })
            } else {
                fetchAccessTokenAndProceed()
            }

//            NotificationCenter.default.post(name: Notification.Name(rawValue: "logged"), object: nil)
            return true
        }
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func fetchAccessTokenAndProceed() {
        //TODO: Show Spinner
        showSpinner(show: true)
        
        AuthenticationManager.shared.fetchAccessToken { (success) in
            
            if success {
                //stop spinner
                DispatchQueue.main.async {
                    self.showSpinner(show: false)
                    self.masterNavigationController = self.storyboard.instantiateViewController(withIdentifier: Storyboard.masterNavigationController) as! MasterNavigationController
                    self.window?.rootViewController = self.masterNavigationController
                }
            } else {
                //show error
                
                print("Error fetching access token.")
            }
        }
    }
    
    private func showSpinner(show: Bool) {
        if show {
            spinnerView.frame = UIScreen.main.bounds
            spinner.center = spinnerView.center
            self.window?.addSubview(spinnerView)
            spinner.startAnimating()
        } else {
            spinnerView.removeFromSuperview()
        }
    }
    

}

