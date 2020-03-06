//
//  NSContext+Extension.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 2/10/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import CoreData

@available(iOS 10, OSX 10.12, watchOS 3.0, tvOS 10, *)
extension NSManagedObjectContext {
    
    /// Main context.
    @objc
    public class var main: NSManagedObjectContext {
        return NSPersist.shared.viewContext
    }
    
    /// Creates and returns new background context.
    @objc
    public class func newBackgroundContext() -> NSManagedObjectContext {
        return NSPersist.shared.newBackgroundContext()
    }
}
