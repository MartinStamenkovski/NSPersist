//
//  NSPersist.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 2/8/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData

/**
 NSPersistentContainer wrapper.
 */
@available(iOS 10, macOS 10.12, watchOS 3.0, tvOS 10, *)
public final class NSPersist: NSPersistentContainer {
    
    private static var containerName: String!
    
    private static var storeURL = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).last
    private static var configurations: [String]!
    
    private override init(name: String, managedObjectModel model: NSManagedObjectModel) {
        super.init(name: name, managedObjectModel: model)
    }
    
    /**
     Setup Core Data Model name.
     
     This should be called once, in AppDelegate  and the name will be used to initialize Core Data container.
     
     - Parameter name: Core Data Model name to be used.
     - Parameter configurations: Additional configurations to load, if any.
     */
    public class func setup(withName name: String, configurations: [String] = []) {
        self.containerName = name
        self.configurations = configurations
    }
    
    /// Singleton shared instance of NSPersist.
    public static let shared: NSPersist = {
        
        let container = NSPersist(name: containerName)
        
        loadConfigurations(in: container)
        
        container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error {
                #if DEBUG
                fatalError(error.localizedDescription)
                #endif
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.undoManager = undoManager
        
        return container
    }()
    
    private static func loadConfigurations(in container: NSPersist) {
        
        if let storeURL = storeURL {
            configurations.forEach { (name) in
                let url = storeURL.appendingPathComponent("\(name.lowercased()).sqlite")
                let storeDescription = NSPersistentStoreDescription(url: url)
                storeDescription.configuration = name
                container.persistentStoreCoordinator.addPersistentStore(with: storeDescription) { ( _ , error) in
                    if let error = error {
                        #if DEBUG
                        fatalError(error.localizedDescription)
                        #endif
                    }
                }
            }
        }
    }
    /**
     Singleton instance of UndoManager
     
     You can use this to perform undo and redo operations.
     */
    public static let undoManager: UndoManager = {
        return UndoManager()
    }()
    
    /**
     Save changes if any.
     
     Calling this method will save all performed changes in the current context.
     
     - Parameter backgroundContext: Specify which context to use to save changes, default is main context.
     */
    public func saveContext(backgroundContext: NSManagedObjectContext? = nil) {
        
        let context = backgroundContext ?? viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            #if DEBUG
            print("Error: \(error), \(error.userInfo)")
            #endif
        }
    }
    
}

//MARK: - Request
@available(iOS 10, OSX 10.12, watchOS 3.0, tvOS 10, *)
extension NSPersist {
    
    /**
     Creates and returns Fetch Request instance.
     
     - Parameter object: NSManagedObject.
     - Parameter completion: The block to execute when NSFetchRequest is created, for further customization.
     */
    public func fetch<T>(_ object: T.Type, completion: ((NSFetchRequest<T>) -> Void)? = nil) -> FetchRequest<T> where T: NSManagedObject {
        return FetchRequest.shared(object: object).fetch(completion: completion)
    }
    
    /**
     Creates and returns Update Request instance.
     
     - Parameter object: NSManagedObject.
     - Parameter completion: The block to execute when NSBatchUpdateRequest is created, for further customization.
     */
    public func update<T>(_ object: T.Type, completion: ((NSBatchUpdateRequest) -> Void)) -> UpdateRequest<T> where T: NSManagedObject {
        return UpdateRequest.shared(object: object).batchRequest(completion)
    }
    
    /**
     Creates and returns Insert Request instance.
     
     - Parameter object: NSManagedObject.
     - Parameter values: List of dictionaries to insert , the keys should match with the Entity attribute names.
     - Parameter context: In which context to execute the request, default is newBackgroundContext.
     - Parameter completion: The block the execute when the request finishes, true if the request is success or false.
     */
    @available(iOS 13, OSX 10.15, watchOS 6.0, tvOS 13, *)
    public func insertBatchAsync<T>(_ object: T.Type, values: [[String: Any]], in context: NSManagedObjectContext = .newBackgroundContext(), completion: @escaping ((Bool) -> Void)) where T: NSManagedObject {
        return InsertRequest.shared(object: object).insertBatchAsync(values, context: context, completion: completion)
    }
  
}

