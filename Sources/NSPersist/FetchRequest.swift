//
//  FetchRequest.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 2/8/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData

@available(iOS 10, *)
public final class FetchRequest<T> where T: NSManagedObject {
    
    var fetchRequest: NSFetchRequest<T>!
    
    private init() { }
    
    static func shared(object: T.Type) -> FetchRequest<T> {
        return FetchRequest<T>()
    }
    
    func fetch(completion: ((NSFetchRequest<T>) -> Void)? = nil) -> Self {
        self.fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        completion?(fetchRequest)
        return self
    }
    
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
    
    public func getAsync(completion: @escaping(([T]) -> Void)) {
        let mainContext = NSPersist.shared.viewContext
        let backgroundContext = NSPersist.shared.newBackgroundContext()
        
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (result) in
            guard let objects = result.finalResult else {
                completion([])
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
            print(error)
            #endif
        }
    }
}
