//
//  UpdateRequest+ObjC.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 3/6/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData
/**
 Update Request
 
 Create and perform update requests.
 */
@available(iOS 10, OSX 10.12, watchOS 3.0, tvOS 10, *)
@objc
public final class UpdateRequestObjC: NSObject {
    
     override init() {
        super.init()
    }
    
    var batchUpdateRequest: NSBatchUpdateRequest!
    
    @objc
    func batchRequest(entityName: String, _ completion: ((NSBatchUpdateRequest) -> Void)) -> Self {
        self.batchUpdateRequest = NSBatchUpdateRequest(entityName: entityName)
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
        The block takes one parameter Bool, true if the request is successful or false.
     */
    @objc
    public func updateBatchAsync(_ completion: @escaping((Bool) -> Void)) {
        let backgroundContext = NSPersist.shared.newBackgroundContext()
        backgroundContext.perform {
            self.executeAsyncUpdate(with: backgroundContext, completion)
        }
    }
    
    @objc
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
