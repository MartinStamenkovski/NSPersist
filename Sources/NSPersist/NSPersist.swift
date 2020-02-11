//
//  NSPersist.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 2/8/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData

public class NSPersist: NSPersistentContainer {
    
    private static var containerName: String!
    
    public static func setup(withName name: String) {
        self.containerName = name
    }
    
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
extension NSPersist {
    
    public func request<T>(_ object: T.Type, completion: ((NSFetchRequest<T>) -> Void)? = nil) -> FetchRequest<T> where T: NSManagedObject {
        return FetchRequest.shared(object: object).fetch(completion: completion)
    }
    
    public func update<T>(_ object: T.Type, completion: ((NSBatchUpdateRequest) -> Void)) -> UpdateRequest<T> where T: NSManagedObject {
        return UpdateRequest.shared(object: object).batchRequest(completion)
    }
    
    @available(iOS 13, *)
    public func insertBatchAsync<T>(_ object: T.Type, values: [[String: Any]], completion: @escaping ((Bool) -> Void)) where T: NSManagedObject {
        InsertRequest.shared(object: object).insertBatch(values, completion: completion)
    }
    
    public func insertAsync<T>(_ object: T.Type, values: [[String: Any]], completion: @escaping ((Bool) -> Void)) where T: NSManagedObject {
        InsertRequest.shared(object: object).insertAsync(values, completion: completion)
    }
}
