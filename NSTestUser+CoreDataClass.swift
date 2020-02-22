//
//  NSTestUser+CoreDataClass.swift
//  NSPersistTests
//
//  Created by Martin Stamenkovski on 2/21/20.
//
//

import Foundation
import CoreData

@objc(NSTestUser)
public class NSTestUser: NSManagedObject {

    @NSManaged public var name: String?
}
