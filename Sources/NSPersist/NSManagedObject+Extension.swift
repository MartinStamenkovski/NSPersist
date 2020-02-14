//
//  NSManagedObject+Update.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 2/9/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData

@available(iOS 10, OSX 10.12, watchOS 3.0, *)
extension NSManagedObject {
    
    /**
     Save changes if any.
     
     Calling this method will save all performed changes in the current context.
     
     - Parameter backgroundContext: Specify which context to use to save changes, default is main context.
     */
    public func save(context: NSManagedObjectContext? = nil) {
        NSPersist.shared.saveContext(backgroundContext: context)
    }
    
    private func request() -> NSFetchRequest<NSManagedObject>? {
        guard let entityName = self.entity.name else { return nil }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        return fetchRequest
    }
    
    public func delete(_ completion: ((Bool) -> Void)? = nil) {
        guard let request = request() else {
            completion?(false)
            return
        }
        let context = NSPersist.shared.viewContext
        do {
            let results = try context.fetch(request)
            for result in results {
                if result == self {
                    context.delete(result)
                    completion?(true)
                }
            }
            NSPersist.shared.saveContext()
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }
    
}

