//
//  FetchRequest+Delete.swift
//  CoreDataStack
//
//  Created by Martin Stamenkovski on 2/8/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData

extension FetchRequest {
    
    public func delete() {
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
    
    public func deleteAsync(completion: @escaping ((Bool) -> Void)) {
        
        let fetchRequest = self.fetchRequest as! NSFetchRequest<NSFetchRequestResult>
        
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
