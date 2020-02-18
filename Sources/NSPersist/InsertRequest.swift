//
//  InsertRequest.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 2/10/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData

/**
 Insert Request
 
 Create and perform insert requests.
 */
@available(iOS 10, OSX 10.12, watchOS 3.0, *)
public final class InsertRequest<T> where T: NSManagedObject {
    
    private init() { }
    
    /**
     Creates new Insert Request.
     
     - Parameter object: NSManagedObject Type
     */
    class func shared(object: T.Type) -> InsertRequest<T> {
        return InsertRequest<T>()
    }
    
    @available(iOS 13, OSX 10.15, watchOS 6.0, tvOS 13, *)
    public func insertBatchAsync(_ values: [[String: Any]], context: NSManagedObjectContext, completion: @escaping ((Bool) -> Void)) {
        let entity = String(describing: T.self)
        
        context.perform {
            do {
                
                let request = NSBatchInsertRequest(entityName: entity, objects: values)
                request.resultType = .objectIDs
                let insertResult = try context.execute(request) as? NSBatchInsertResult
                
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

