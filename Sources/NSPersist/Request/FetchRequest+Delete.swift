//
//  FetchRequest+Delete.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 2/8/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData

@available(iOS 10, OSX 10.12, watchOS 3.0, tvOS 10, *)
public extension FetchRequest {
    
    /**
     Delete request.
     
     Perform delete request on the main context.
     */
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
    func deleteAsync(_ completion: @escaping ((Bool) -> Void)) {
        
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
