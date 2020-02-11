//
//  NSManagedObject+Update.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 2/9/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData

extension NSManagedObject {
    
    public func save(context: NSManagedObjectContext? = nil) {
        NSPersist.shared.saveContext(backgroundContext: context)
    }
}

