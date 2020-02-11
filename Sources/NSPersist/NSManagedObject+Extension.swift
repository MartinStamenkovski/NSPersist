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
    
    public func save(context: NSManagedObjectContext? = nil) {
        NSPersist.shared.saveContext(backgroundContext: context)
    }
}

