//
//  UpdateRequest.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 2/9/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData
/**
 Update Request
 
 Create and perform update requests.
 */
@available(iOS 10, OSX 10.12, watchOS 3.0, *)
public final class UpdateRequest<T> where T: NSManagedObject {
    
    private init() { }
    
    var batchUpdateRequest: NSBatchUpdateRequest!
    
    /**
     Creates new Update Request.
     
     - Parameter object: NSManagedObject Type
     */
    class func shared(object: T.Type) -> UpdateRequest<T> {
        return UpdateRequest<T>()
    }
    
    func batchRequest(_ completion: ((NSBatchUpdateRequest) -> Void)) -> Self {
        self.batchUpdateRequest = NSBatchUpdateRequest(entityName: String(describing: T.self))
        self.batchUpdateRequest.resultType = .updatedObjectIDsResultType
        completion(batchUpdateRequest)
        return self
    }
    
    /**
     Update request asynchronously.
     
     Performs the update request asynchronously, using the NSBatchUpdateRequest.
     
     - NSBatchUpdateRequest:
     
     A request to Core Data to do a batch update of data in a persistent store without loading any data into memory.
     
     - Parameter completion:
     The block to execute  after the request finishes.
     
     This block takes one parameter Bool, true if the request is successful or false.
     */
    public func updateBatchAsync(_ completion: @escaping((Bool) -> Void)) {
        let backgroundContext = NSPersist.shared.newBackgroundContext()
        backgroundContext.perform {
            self.executeAsyncUpdate(with: backgroundContext, completion)
        }
    }
    
    private func executeAsyncUpdate(with context: NSManagedObjectContext, _ completion: @escaping((Bool) -> Void)) {
        do {
            let result = try context.execute(batchUpdateRequest) as? NSBatchUpdateResult
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
