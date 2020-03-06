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
@available(iOS 13, OSX 10.15, watchOS 6.0, tvOS 13, *)
public final class InsertRequest<T> where T: NSManagedObject {
    
    private init() { }
    
    /**
     Creates new Insert Request.
     
     - Parameter object: NSManagedObject Type
     */
    class func shared(object: T.Type) -> InsertRequest<T> {
        return InsertRequest<T>()
    }
    /**
        Creates NSBatchInsertRequest.
    
        - Parameter values: List of dictionaries to insert , the keys should match with the Entity attribute names.
        - Parameter context: In which context to execute the request, default is newBackgroundContext.
        - Parameter completion: The block the execute when the request finishes, true if the request is success or false.
     */
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

