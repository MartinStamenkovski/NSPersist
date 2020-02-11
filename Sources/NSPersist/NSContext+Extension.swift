//
//  NSContext+Extension.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 2/10/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData

@available(iOS 10, *)
extension NSManagedObjectContext {
    
    public static var main: NSManagedObjectContext {
        return NSPersist.shared.viewContext
    }
}
