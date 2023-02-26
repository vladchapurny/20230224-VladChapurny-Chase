//
//  _0230224_VladChapurny_ChaseTests.swift
//  20230224-VladChapurny-ChaseTests
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import XCTest
@testable import _0230224_VladChapurny_Chase

class _0230224_VladChapurny_ChaseTests: XCTestCase {
    
    var roundResultDown: Double!
    var roundResultUp: Double!
    var stringifyDouble: Double!
    var stringifyString: String!
    var stringifyBool: Bool!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        roundResultDown = 30.4999
        roundResultUp = 30.5
        stringifyDouble = 0.51239
        stringifyString = "test"
        stringifyBool = true
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        roundResultDown = nil
        roundResultUp = nil
        stringifyDouble = nil
        stringifyString = nil
        stringifyBool = nil
    }

    func testBasicUtilTestStringify() throws {
        XCTAssertEqual(Utils.Stringify(stringifyDouble), "0.51239")
        XCTAssertEqual(Utils.Stringify(stringifyString), "test")
        XCTAssertEqual(Utils.Stringify(stringifyBool), "true")
        
        let genericNil: Optional<Bool> = .none
        XCTAssertEqual(Utils.Stringify(genericNil), "---")
    }
    
    func testBasicUtilTestRoundTemp() throws {
        XCTAssertEqual(Utils.RoundTemp(roundResultUp), 31)
        XCTAssertEqual(Utils.RoundTemp(roundResultDown), 30)
        XCTAssertNil(Utils.RoundTemp(nil))
    }

    // TODO: Add performance tests (self.measure)
}
