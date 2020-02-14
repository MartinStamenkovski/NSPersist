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
@available(iOS 10, macOS 10.12, watchOS 3.0, *)
public final class NSPersist: NSPersistentContainer {
    
    private static var containerName: String!
    
    /**
     Setup Core Data Model name.
     
     This should be called once, in AppDelegate or SceneDelegate and the name will be used to initialize CoreData container.
     
     - Parameter name: Core Data Model name to be used.
     */
    public class func setup(withName name: String) {
        self.containerName = name
    }
    
    /// Singleton shared instance of NSPersist.
    public static let shared: NSPersist = {
        
        let container = NSPersist(name: containerName)
        
        container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error {
                #if DEBUG
                fatalError(error.localizedDescription)
                #endif
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return container
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
@available(iOS 10, OSX 10.12, watchOS 3.0, *)
extension NSPersist {
    
    public func request<T>(_ object: T.Type, completion: ((NSFetchRequest<T>) -> Void)? = nil) -> FetchRequest<T> where T: NSManagedObject {
        return FetchRequest.shared(object: object).fetch(completion: completion)
    }
    
    public func update<T>(_ object: T.Type, completion: ((NSBatchUpdateRequest) -> Void)) -> UpdateRequest<T> where T: NSManagedObject {
        return UpdateRequest.shared(object: object).batchRequest(completion)
    }
    
    @available(iOS 13, OSX 10.15, watchOS 6.0, *)
    public func insertBatchAsync<T>(_ object: T.Type, values: [[String: Any]], in context: NSManagedObjectContext = .newBackgroundContext(), completion: @escaping ((Bool) -> Void)) where T: NSManagedObject {
        InsertRequest.shared(object: object).insertBatchAsync(values, context: context, completion: completion)
    }
    
    public func insertAsync<T>(_ object: T.Type, values: [[String: Any]], in context: NSManagedObjectContext = .newBackgroundContext(), completion: @escaping ((Bool) -> Void)) where T: NSManagedObject {
        InsertRequest.shared(object: object).insertAsync(values, context: context, completion: completion)
    }
}
