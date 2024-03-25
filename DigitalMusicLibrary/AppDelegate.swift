//
//  AppDelegate.swift
//  DigitalMusicLibrary
//
//  Created by Amar Nagargoje on 3/4/24.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var artists: [Artist] = []
    var albums: [Albums] = []
    var songs: [Songs] = []
    var genres: [Genres] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DigitalMusicLibrary")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
