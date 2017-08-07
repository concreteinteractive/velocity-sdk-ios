//
//  VLTDBTests.swift
//  Example
//
//  Created by Vytautas Galaunia on 16/11/2016.
//  Copyright © 2016 Vytautas Galaunia. All rights reserved.
//

import XCTest

class VLTDBTests: XCTestCase {

    var velocityDb: VLTDB!
    
    override func setUp() {
        super.setUp()
        velocityDb = VLTDB()
    }
    
    func testDBNotNil() {
        XCTAssert(velocityDb != nil, "CoreData model should exists.")
    }

    func testMotionCreation() {
        let motion = velocityDb.createMotion(withName: "LOL", weight: 5, inMoc: velocityDb.moc);
        XCTAssert(motion != nil, "motion shouldn't be equal to nil.")

        velocityDb.deleteAllMotions(velocityDb.moc)

        let allMotions = velocityDb.fetchAllMotions(inMoc: velocityDb.moc)
        XCTAssert(allMotions.count == 0, "All motions are supposed to be deleted.")
    }

    func testNotificationCreation() {
        let note = velocityDb.createNotification(withActivityName: "Walking",
                                                 notificationId: "213",
                                                 message: "GO OUT FROM HERE!",
                                                 inMoc: velocityDb.moc)
        XCTAssert(note != nil, "motion shouldn't be equal to nil.")
        XCTAssertEqual("walking", note?.activityName, "Activity names should match.")
    }
    
}
