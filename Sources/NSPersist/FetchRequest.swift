//
//  FetchRequest.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 2/8/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData
/**
 Fetch Request
 
 Create and perform fetch requests.
 */
@available(iOS 10, OSX 10.12, watchOS 3.0, tvOS 10, *)
public final class FetchRequest<T> where T: NSManagedObject {
    
    var fetchRequest: NSFetchRequest<T>!
    
    private init() { }
    
    /**
     Creates new Fetch Request.
     
     - Parameter object: NSManagedObject Type
     - Returns
     Fetch Request
     */
    static func shared(object: T.Type) -> FetchRequest<T> {
        return FetchRequest<T>()
    }
    
    func fetch(completion: ((NSFetchRequest<T>) -> Void)? = nil) -> Self {
        self.fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        completion?(fetchRequest)
        return self
    }
    
    /**
     Perform fetch request.
     
     Returns array of objects that match with the provided object and other specified criteria.
     */
    public func get() -> [T] {
        let mainContext = NSPersist.shared.viewContext
        do {
            return try mainContext.fetch(fetchRequest)
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        return []
    }
    
    /**
    Perform fetch request asynchronously.
    
     - Parameter completion:
        The block to execute when the request finishes.
     
        The block takes one parameter, array of objects that match with the provided object and specified criteria, or nil if error occurred.
    */
    public func getAsync(completion: @escaping(([T]?) -> Void)) {
        let mainContext = NSPersist.shared.viewContext
        let backgroundContext = NSPersist.shared.newBackgroundContext()
        
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (result) in
            guard let objects = result.finalResult else {
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                let fetchedObjects = objects
                    .compactMap { $0.objectID }
                    .compactMap { mainContext.object(with: $0) as? T }
                completion(fetchedObjects)
            }
        }
        
        do {
            try backgroundContext.execute(asyncRequest)
        } catch {
            #if DEBUG
            fatalError(error.localizedDescription)
            #endif
        }
    }
}
