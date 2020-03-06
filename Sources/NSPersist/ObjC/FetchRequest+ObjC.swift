//
//  FetchRequest+ObjC.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 3/6/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData
/**
 Fetch Request
 
 Create and perform fetch requests.
 */
@available(iOS 10, OSX 10.12, watchOS 3.0, tvOS 10, *)
@objc
public final class FetchRequestObjC: NSObject {
    
    var fetchRequest: NSFetchRequest<NSManagedObject>!
    
    override init() {
        super.init()
    }
    
    @objc
    func fetch(entityName: String, completion: ((NSFetchRequest<NSManagedObject>) -> Void)? = nil) -> Self {
        self.fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        completion?(fetchRequest)
        return self
    }
    
    /**
     Perform fetch request.
     
     Returns array of objects that match with the provided object and other specified criteria.
     */
    @objc
    public func get() -> [NSManagedObject] {
        let mainContext = NSPersist.shared.viewContext
        
        do {
            return try mainContext.fetch(fetchRequest)
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        return []
    }
    
    /**
     Perform fetch request asynchronously.
     
     - Parameter completion:
     The block to execute when the request finishes.
     
     The block takes one parameter, array of objects that match with the provided object and specified criteria, or nil if error occurred.
     */
    @objc
    public func getAsync(completion: @escaping(([NSManagedObject]?) -> Void)) {
        let mainContext = NSPersist.shared.viewContext
        let backgroundContext = NSPersist.shared.newBackgroundContext()
        
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (result) in
            guard let objects = result.finalResult else {
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                let fetchedObjects = objects
                    .compactMap { $0.objectID }
                    .compactMap { mainContext.object(with: $0) }
                completion(fetchedObjects)
            }
        }
        
        do {
            try backgroundContext.execute(asyncRequest)
        } catch {
            #if DEBUG
            fatalError(error.localizedDescription)
            #endif
        }
    }
}

//MARK: - Delete Request
@objc
public extension FetchRequestObjC {
    
    /**
     Delete request.
     
     Perform delete request on the main context.
     */
    @objc
    func delete() {
        let mainContext = NSPersist.shared.viewContext
        do {
            let results = try mainContext.fetch(fetchRequest)
            for result in results {
                mainContext.delete(result)
            }
            NSPersist.shared.saveContext()
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }
    
    /**
     Delete request asynchronously.
     
     Performs the delete request asynchronously, using the NSBatchDeleteRequest.
     
     - NSBatchDeleteRequest:
     
     A request to Core Data to do a batch delete of data in a persistent store without loading any data into memory.
     
     
     - Parameter completion:
     The block to execute  after the request finishes.
     This block takes one parameter Bool, true if the request is successful or false.
     */
    @objc
    func deleteAsync(completion: @escaping ((Bool) -> Void)) {
        
        guard let fetchRequest = self.fetchRequest as? NSFetchRequest<NSFetchRequestResult> else { return }
        
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDelete.resultType = .resultTypeObjectIDs
        
        let backgroundContext = NSPersist.shared.newBackgroundContext()
        backgroundContext.perform {
            do {
                
                let result = try backgroundContext.execute(batchDelete) as? NSBatchDeleteResult
                guard let objectIds = result?.result as? [NSManagedObjectID] else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return
                }
                
                let changes = [NSUpdatedObjectsKey: objectIds]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [.main])
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
                #if DEBUG
                print(error)
                #endif
            }
        }
    }
    
}
