//
//  _0230224_VladChapurny_ChaseUITestsLaunchTests.swift
//  20230224-VladChapurny-ChaseUITests
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import XCTest

class _0230224_VladChapurny_ChaseUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
