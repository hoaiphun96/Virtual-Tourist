//
//  AppDelegate.swift
//  CoolNotes
//
//  Created by Fernando Rodríguez Romero on 09/03/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//

import UIKit
import CoreData

// MARK: - AppDelegate: UIResponder, UIApplicationDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Properties
    
    var window: UIWindow?
   
    func applicationWillResignActive(_ application: UIApplication) {
        stack.save()
        
    }
    // MARK: - Core Data stack
    let stack = CoreDataStack(modelName: "Virtual_Tourist")!
   
    func applicationDidEnterBackground(_ application: UIApplication) {
        stack.save()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Start Autosaving
        stack.autoSave(60)
        return true
    }
}
