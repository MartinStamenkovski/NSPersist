//
//  NSPersistTests.swift
//  NSPersistTests
//
//  Created by Martin Stamenkovski on 2/8/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import XCTest
@testable import NSPersist

class NSPersistTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPersistentContainerSetup() {
        NSPersist.setup(withName: "TestModel")
        XCTAssertNotNil(NSPersist.shared)
    }
    
    func testAddUser() {
        NSPersist.setup(withName: "TestModel")
        let user = TestUser(context: NSPersist.shared.viewContext)
        user.name = "Test Name"
        NSPersist.shared.saveContext()
        
        //let expectation = self.expectation(description: "load_users")
        let users = NSPersist
            .shared
            .request(TestUser.self)
            .get()
        
        XCTAssertTrue(users.count > 0)
        XCTAssertNotNil(users.last)
        XCTAssertTrue(users.last?.name == "Test Name")
    }
    
    func testAsyncRequestNoRetainCycle() {
        NSPersist.setup(withName: "TestModel")

        var captureObject = NSObject()
        weak var weakObject = captureObject
        
        let expectation = self.expectation(description: "async_request")
        _ = NSPersist
            .shared
            .request(TestUser.self, completion: {[captureObject] (request) in
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
        NSPersist.setup(withName: "TestModel")

        var captureObject = NSObject()
        weak var weakObject = captureObject
        
        let expectation = self.expectation(description: "fetchrequest")
        
        _ = NSPersist
            .shared
            .request(TestUser.self, completion: {[captureObject] (request) in
                request.predicate = NSPredicate(format: "name = %@", "Martin")
                _ = captureObject
                expectation.fulfill()
            })
            .get()
        
        wait(for: [expectation], timeout: 1)
        captureObject = NSObject()
        XCTAssertNil(weakObject)
    }
    
    func testDeleteAsyncNoRetainCycle() {
        NSPersist.setup(withName: "TestModel")

        var captureObject = NSObject()
        weak var weakObject = captureObject
        
        let expectation = self.expectation(description: "delete_async")
        
        NSPersist
            .shared
            .request(TestUser.self)
            .deleteAsync {[captureObject] (didDelete) in
                _ = captureObject
                expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        captureObject = NSObject()
        XCTAssertNil(weakObject)
    }
    
    func testUpdateBatchAsyncNoRetainCycle() {
        NSPersist.setup(withName: "TestModel")

        var captureObject = NSObject()
        weak var weakObject = captureObject
        
        let expectation = self.expectation(description: "update_async")
        
        NSPersist
            .shared
            .update(TestUser.self) { (request) in
                request.predicate = NSPredicate(format: "favorite == true")
                request.propertiesToUpdate = ["favorite" : false]
        }.updateBatchAsync {[captureObject] _ in
            _ = captureObject
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        captureObject = NSObject()
        XCTAssertNil(weakObject)
    }
    
    @available(iOS 13, *)
    func testBatchInsertAsyncNoRetainCycle() {
        NSPersist.setup(withName: "TestModel")

        var captureObject = NSObject()
        weak var weakObject = captureObject
        
        let expectation = self.expectation(description: "batch_insert")
       
        let users = [
            [
                "name" : "Test",
                "favorite": false
            ],
            [
                "name" : "Another user",
                "favorite": true
            ]
        ]
        
        NSPersist
            .shared
            .batchInsertAsync(TestUser.self, objects: users) { [captureObject] _ in
                _ = captureObject
                expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        captureObject = NSObject()
        XCTAssertNil(weakObject)
    }
}
