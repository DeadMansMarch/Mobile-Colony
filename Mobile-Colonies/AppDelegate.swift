//
//  AppDelegate.swift
//  Mobile-Colonies
//
//  Created by Liam Pierce on 11/15/17.
//  Copyright © 2017 Virtual Earth. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var ListingController:ColonyListingController!;
    var GameController:GridViewController!;

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        ListingController = splitViewController.viewControllers[0] as! ColonyListingController
        GameController = splitViewController.viewControllers[1] as! GridViewController
        
        ListingController.gameController = GameController;
        GameController.leftController = ListingController
        
        let colonies = ListingController.loadColonies();
        print("Loaded from file");
        if (colonies != nil){
            if (colonies!.count > 0){
                GameController.currentColony = colonies!.first!
            }
            for colony in colonies!{
                print(colony);
                ListingController.colonies.createColony(Data: colony)
            }
        }
        
        print("Loaded from file");
        let templates = ListingController.loadTemplates();
        if (templates != nil){
            for template in templates!{
                print(template);
                ListingController.usertemplates.createColony(Data: template)
            }
        }
        
        splitViewController.presentsWithGesture = false;
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        ListingController.saveColonies();
        ListingController.saveTemplates();
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        ListingController.saveColonies();
        ListingController.saveTemplates();
    }


}

