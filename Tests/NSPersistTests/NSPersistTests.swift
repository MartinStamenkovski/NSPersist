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
        NSPersist.setup(withName: "NSPersistTestModel")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPersistentContainerSetup() {
        
        XCTAssertNotNil(NSPersist.shared)
    }
    
    func testInsertRecord() {
        XCTAssertNotNil(NSPersist.shared)
        
        let user = NSTestUser(context: .main)
        user.name = "Test User"
        user.save()
        
        let users = NSPersist.shared.fetch(NSTestUser.self).get()
        
        XCTAssertNotNil(users.last)
        XCTAssertEqual(users.last?.name, "Test User")
    }
    
    func testAsyncRequestNoRetainCycle() {
        
        XCTAssertNotNil(NSPersist.shared)
        
        var captureObject = NSObject()
        weak var weakObject = captureObject
        
        
        let expectation = self.expectation(description: "async_request")
        _ = NSPersist
            .shared
            .fetch(NSTestUser.self, completion: {[captureObject] (request) in
                request.predicate = NSPredicate(format: "name = %@", "Test Name")
                _ = captureObject
            })
            .getAsync(completion: { [weak captureObject] users in
                _ = captureObject
                expectation.fulfill()
            })
        
        wait(for: [expectation], timeout: 1)
        captureObject = NSObject()
        XCTAssertNil(weakObject)
    }
    
    func testFetchRequestNoRetainCycle() {
        
        XCTAssertNotNil(NSPersist.shared)
        
        var captureObject = NSObject()
        weak var weakObject = captureObject
        
        let expectation = self.expectation(description: "fetchrequest")
        
        _ = NSPersist
            .shared
            .fetch(NSTestUser.self, completion: {[captureObject] (request) in
                request.predicate = NSPredicate(format: "name = %@", "Martin")
                _ = captureObject
                expectation.fulfill()
            })
            .get()
        
        wait(for: [expectation], timeout: 1)
        captureObject = NSObject()
        XCTAssertNil(weakObject)
    }
    
    
    func testUpdateBatchAsyncNoRetainCycle() {
        
        XCTAssertNotNil(NSPersist.shared)
        
        var captureObject = NSObject()
        weak var weakObject = captureObject
        
        let expectation = self.expectation(description: "update_async")
        
        NSPersist
            .shared
            .update(NSTestUser.self) { (request) in
                request.predicate = NSPredicate(format: "name = %@", "Test Name")
                request.propertiesToUpdate = ["name" : "User Update"]
        }.updateBatchAsync {[captureObject] _ in
            _ = captureObject
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        captureObject = NSObject()
        XCTAssertNil(weakObject)
    }
    
    @available(iOS 13, macOS 10.15, tvOS 13, *)
    func testBatchInsertAsyncNoRetainCycle() {
        
        XCTAssertNotNil(NSPersist.shared)
        
        var captureObject = NSObject()
        weak var weakObject = captureObject
        
        let expectation = self.expectation(description: "batch_insert")
        
        let users = [
            [
                "name" : "Test",
            ],
            [
                "name" : "Another user",
            ]
        ]
        
        NSPersist
            .shared
            .insertBatchAsync(NSTestUser.self, values: users) { [captureObject] _ in
                _ = captureObject
                expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        captureObject = NSObject()
        XCTAssertNil(weakObject)
    }
    
    func testDeleteAsyncNoRetainCycle() {
        
        XCTAssertNotNil(NSPersist.shared)
        
        var captureObject = NSObject()
        weak var weakObject = captureObject
        
        let expectation = self.expectation(description: "delete_async")
        
        NSPersist
            .shared
            .fetch(NSTestUser.self)
            .deleteAsync {[captureObject] (didDelete) in
                _ = captureObject
                expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        captureObject = NSObject()
        XCTAssertNil(weakObject)
    }
}
