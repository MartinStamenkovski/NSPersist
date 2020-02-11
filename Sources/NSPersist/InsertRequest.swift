//
//  InsertRequest.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 2/10/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData

@available(iOS 10, *)
public class InsertRequest<T> where T: NSManagedObject {
    
    private init() { }
    
    class func shared(object: T.Type) -> InsertRequest<T> {
        return InsertRequest<T>()
    }
    
    @available(iOS 13, *)
    public func insertBatch(_ values: [[String: Any]], completion: @escaping ((Bool) -> Void)) {
        let entity = String(describing: T.self)
        
        let backgroundContext = NSPersist.shared.newBackgroundContext()
        
        backgroundContext.perform {
            do {
                
                let request = NSBatchInsertRequest(entityName: entity, objects: values)
                request.resultType = .objectIDs
                let insertResult = try backgroundContext.execute(request) as? NSBatchInsertResult
                
                guard let objectIds = insertResult?.result as? [NSManagedObjectID] else {
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
                completion(false)
                #if DEBUG
                print(error)
                #endif
            }
        }
    }
}

extension InsertRequest {
    
    public func insertAsync(_ values: [[String: Any]], completion: @escaping ((Bool) -> Void)) {
        let backgroundContext = NSPersist.shared.newBackgroundContext()
        
        backgroundContext.perform {
            for value in values  {
                let object = T(context: backgroundContext)
                for (key, value) in value {
                    object.setValue(value, forKey: key)
                }
            }
            NSPersist.shared.saveContext(backgroundContext: backgroundContext)
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
}
