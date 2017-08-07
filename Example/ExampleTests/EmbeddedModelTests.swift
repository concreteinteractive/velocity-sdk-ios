//
//  EmbeddedModelTests.swift
//  Example
//
//  Created by Vytautas Galaunia on 16/11/2016.
//  Copyright © 2016 Vytautas Galaunia. All rights reserved.
//

import XCTest
import Foundation
@testable import Example

class EmbeddedModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testIfModelGetsCreated() {
        XCTAssert(FileManager.default.fileExists(atPath: VLTEmbeddedModel.modelURL().path), "CoreData model should exists.")
    }
}
