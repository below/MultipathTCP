//
//  MultipathTCPTests.swift
//  MultipathTCPTests
//
//  Created by Alexander v. Below on 07.08.17.
//  Copyright © 2017 Deutsche Telekom AG. All rights reserved.
//

import XCTest
@testable import MultipathTCP

class MultipathTCPTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func verifySlowStart (_ ss : SlowStart) {
        XCTAssertEqual(ss.rtt, 12.0)
        XCTAssertEqual(ss.rtt2, 6)
        XCTAssertEqual(ss.rto, 248)
        XCTAssertEqual(ss.cwnd, 10)
    }
    
    func testRTSpecDecoding () {
        let data = "{\"rtt\":12.0,\"rtt2\":6,\"rto\":248,\"cwnd\":10}".data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
        let ss = try decoder.decode(SlowStart.self
            , from: data)
            XCTAssertNotNil(ss, "Unexpected Nil found")
            verifySlowStart(ss)
        }
        catch {
        print ("Error")
        }
        print ("foo")
    }
    
    
}
