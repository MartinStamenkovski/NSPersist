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
        NSPersist.shared.request(NSTestUser.self).delete()
        
        super.tearDown()
    }
    
    func testAverage() {
        XCTAssertNotNil(NSPersist.shared)
        let countResult = NSTestUser.aggregate(for: "booksRead", type: .average)
        XCTAssertNotNil(countResult)
        XCTAssertNotNil(countResult?.first)
        XCTAssertNotNil(countResult?.first?["average"])
        XCTAssertTrue(countResult?.first?["average"] as! Int64 == 1)
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
    
    func testMax() {
        XCTAssertNotNil(NSPersist.shared)
        let countResult = NSTestUser.aggregate(for: "booksRead", type: .max)
        XCTAssertNotNil(countResult)
        XCTAssertNotNil(countResult?.last)
        XCTAssertNotNil(countResult?.last?["max"])
        XCTAssertTrue(countResult?.last?["max"] as! Int64 == 2)
    }
    
    func testMin() {
        XCTAssertNotNil(NSPersist.shared)
        let countResult = NSTestUser.aggregate(for: "booksRead", type: .min)
        XCTAssertNotNil(countResult)
        XCTAssertNotNil(countResult?.last)
        XCTAssertNotNil(countResult?.last?["min"])
        XCTAssertTrue(countResult?.last?["min"] as! Int64 == 0)
    }
}
