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
     */
    public class func setup(withName name: String, configurations: [String] = []) {
        self.containerName = name
        self.configurations = configurations
    }
    
    /// Singleton shared instance of NSPersist.
    public static let shared: NSPersist = {
        
        let container = NSPersist(name: containerName)
        
        addConfigurations(in: container)
        
        container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error {
                #if DEBUG
                fatalError(error.localizedDescription)
                #endif
            }
        })
        container.persistentStoreCoordinator.persistentStores.forEach { (store) in
            print(store.configurationName)
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.undoManager = undoManager
        
        return container
    }()
    
    private static func addConfigurations(in container: NSPersist) {
        
        if let storeURL = storeURL {
            configurations.forEach { (name) in
                let url = storeURL.appendingPathComponent("\(name.lowercased()).sqlite")
                let storeDescription = NSPersistentStoreDescription(url: url)
                storeDescription.configuration = name
                container.persistentStoreCoordinator.addPersistentStore(with: storeDescription) { ( _ , error) in
                    if let error = error {
                        #if DEBUG
                        print(error)
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
    
    public func request<T>(_ object: T.Type, completion: ((NSFetchRequest<T>) -> Void)? = nil) -> FetchRequest<T> where T: NSManagedObject {
        return FetchRequest.shared(object: object).fetch(completion: completion)
    }
    
    public func update<T>(_ object: T.Type, completion: ((NSBatchUpdateRequest) -> Void)) -> UpdateRequest<T> where T: NSManagedObject {
        return UpdateRequest.shared(object: object).batchRequest(completion)
    }
    
    @available(iOS 13, OSX 10.15, watchOS 6.0, tvOS 13, *)
    public func insertBatchAsync<T>(_ object: T.Type, values: [[String: Any]], in context: NSManagedObjectContext = .newBackgroundContext(), completion: @escaping ((Bool) -> Void)) where T: NSManagedObject {
        return InsertRequest.shared(object: object).insertBatchAsync(values, context: context, completion: completion)
    }
    
    public func insertAsync<T>(_ object: T.Type, values: [[String: Any]], in context: NSManagedObjectContext = .newBackgroundContext(), completion: @escaping ((Bool) -> Void)) where T: NSManagedObject {
        return InsertRequest.shared(object: object).insertAsync(values, context: context, completion: completion)
    }
}
