//
//  Persistence.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 14/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation
import CoreData

class Persistence {
    
    static let shared = Persistence()
    
    private let modelName       = "digidentity2"
    private let databaseName    = "digidentity2"
    
    init() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveContextDidSaveNotification(notification:)), name:NSNotification.Name.NSManagedObjectContextDidSave, object:nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    // MARK: - Setup model and database
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.decos.IMC" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.last!
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent(self.databaseName + ".sqlite")
        
        #if DEBUG
        print("*** CoreData \(url)")
        #endif
        
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [
                NSMigratePersistentStoresAutomaticallyOption : true,
                NSInferMappingModelAutomaticallyOption : true
                ])
            
        } catch let error {
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error)")
            abort()
        }
        
        return coordinator
    }()
    
    // MARK: - Managed object contexts
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        
        if let coordinator = self.persistentStoreCoordinator {
            
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator
            context.undoManager = nil
            context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            return context
        }
        
        return nil
    }()
    
    func createNewManagedObjectContext() -> NSManagedObjectContext {
        
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        context.undoManager = nil
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        //        if let main = managedObjectContext {
        //
        //            context.parent = main
        //        }
        
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return context
    }
    
    @objc func didReceiveContextDidSaveNotification(notification: Notification) {
        
        let sender = notification.object as! NSManagedObjectContext
        
        if sender != self.managedObjectContext {
            
            self.managedObjectContext?.perform {
                
                DispatchQueue.main.async {
                    
                    self.managedObjectContext?.mergeChanges(fromContextDidSave: notification)
                }
            }
        }
    }
    
}
