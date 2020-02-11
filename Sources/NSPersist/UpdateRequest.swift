//
//  UpdateRequest.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 2/9/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData

@available(iOS 10, *)
public final class UpdateRequest<T> where T: NSManagedObject {
    
    private init() { }
    
    var batchUpdateRequest: NSBatchUpdateRequest!
    
    class func shared(object: T.Type) -> UpdateRequest<T> {
        return UpdateRequest<T>()
    }
    
    func batchRequest(_ completion: ((NSBatchUpdateRequest) -> Void)) -> Self {
        self.batchUpdateRequest = NSBatchUpdateRequest(entityName: String(describing: T.self))
        self.batchUpdateRequest.resultType = .updatedObjectIDsResultType
        completion(batchUpdateRequest)
        return self
    }
    
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
