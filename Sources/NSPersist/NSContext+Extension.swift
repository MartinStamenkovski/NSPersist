//
//  NSContext+Extension.swift
//  CoreDataStack
//
//  Created by Martin Stamenkovski on 2/10/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    public static var main: NSManagedObjectContext {
        return NSPersist.shared.viewContext
    }
}
