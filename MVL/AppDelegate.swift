//
//  AppDelegate.swift
//  MVL
//
//  Created by Thy Nguyen on 11/9/21.
//

import UIKit
import CoreData
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    GMSServices.provideAPIKey(Constant.googleMapAPIKey)
    
    return true
  }

}

