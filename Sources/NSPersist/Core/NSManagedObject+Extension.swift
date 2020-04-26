//
//  NSManagedObject+Update.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 2/9/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData

@available(iOS 10, OSX 10.12, watchOS 3.0, tvOS 10, *)
extension NSManagedObject {
    
    /**
     Save changes if any.
     
     Calling this method will save all performed changes in the current context.
     
     - Parameter context: Specify which context to use to save changes, default is main context.
     */
    public func save(context: NSManagedObjectContext? = nil) {
        NSPersist.shared.saveContext(backgroundContext: context)
    }
    
    /// Create request from the current NSManagedObject.
    private func request() -> NSFetchRequest<NSManagedObject>? {
        guard let entityName = self.entity.name else { return nil }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        return fetchRequest
    }
    
    /**
     Delete current object.
     
     - Parameter completion:
        The block to execute when deletion finishes.
        The block takes one parameter Bool, true if the request is success or false.
     */
    public func delete(_ completion: ((Bool) -> Void)? = nil) {
        guard let request = self.request() else {
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


extension NSManagedObject {
    
    public static func group(by properties: [String]) -> [[String: Any]]? {
        
        let request = fetchRequest()
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = properties
        request.propertiesToFetch = properties
        request.resultType = .dictionaryResultType
        
        let context = NSPersist.shared.viewContext
        do {
            return try context.fetch(request) as? [[String: Any]]
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        return nil
    }
    /**
    Count number of records.
    
    - Parameter keys: Keys to count by.
    */
    public static func count(by keys: [String]) -> [[String: Any]]? {
        let keypathExpression = keys.map { NSExpression(forKeyPath: $0) }
        let expression = NSExpression(forFunction: "count:", arguments: keypathExpression)
        
        let countExpression = NSExpressionDescription()
        countExpression.expression = expression
        countExpression.name = "count"
        countExpression.expressionResultType = .integer64AttributeType
        
        var propertiesToFetch: [Any] = keys
        propertiesToFetch.append(countExpression)
        
        let request = fetchRequest()
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = keys
        request.propertiesToFetch = propertiesToFetch
        request.resultType = .dictionaryResultType
        
        let context = NSPersist.shared.viewContext
        do {
            return try context.fetch(request) as? [[String: Any]]
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        return nil
    }
}
