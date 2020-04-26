//
//  NSPersistTests.swift
//  NSPersistTests
//
//  Created by Martin Stamenkovski on 2/8/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import XCTest
@testable import NSPersist

@available(iOS 10, OSX 10.12, tvOS 10, *)
class NSPersistTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        NSPersist.setup(withName: "NSPersistTestModel")
        for i in 0..<3 {
            let user = NSTestUser(context: .main)
            user.name = "\(i)"
            user.booksRead = Int32(i)
        }
        NSPersist.shared.saveContext()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        NSPersist.shared.fetch(NSTestUser.self).delete()
        super.tearDown()
    }
    
    func testCount() {
        XCTAssertNotNil(NSPersist.shared)
        
        let countResult = NSTestUser.aggregate(for: "name", type: .count)
        XCTAssertNotNil(countResult)
        XCTAssertNotNil(countResult?.first)
        XCTAssertNotNil(countResult?.first?["count"])
        XCTAssertTrue(countResult?.first?["count"] as! Int64 == 3)
    }
    
    func testSum() {
        XCTAssertNotNil(NSPersist.shared)
        
        let sumResult = NSTestUser.aggregate(for: "booksRead", type: .sum)
        XCTAssertNotNil(sumResult)
        XCTAssertNotNil(sumResult?.first?["sum"])
        XCTAssertTrue(sumResult?.first?["sum"] as! Int64 == 3)
    }
    
   
}
