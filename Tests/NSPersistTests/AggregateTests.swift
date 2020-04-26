//
//  AggregateTests.swift
//  NSPersist
//
//  Created by Martin Stamenkovski on 4/26/20.
//

import XCTest
@testable import NSPersist

@available(iOS 10, OSX 10.12, tvOS 10, *)
class AggregateTests: NSPersistTests {
    
    func testCount() {
        let countResult = NSTestUser.aggregate(for: "name", type: .count)
        XCTAssertNotNil(countResult)
        XCTAssertNotNil(countResult?.first)
        XCTAssertNotNil(countResult?.first?["count"])
    }
    
    func testSum() {
        for i in 0..<3 {
            let user = NSTestUser(context: .main)
            user.name = "\(i)"
            user.booksRead = Int32(i)
        }
        NSPersist.shared.saveContext()
        
        let sumResult = NSTestUser.aggregate(for: "booksRead", type: .sum)
        XCTAssertNotNil(sumResult)
        XCTAssertNotNil(sumResult?.first?["sum"])
        XCTAssertTrue(sumResult?.first?["sum"] as! Int64 == 3)
    }
    
}
