//
//  2D-BounceTests.swift
//  2D-Bounce
//
//  Created by Mikhail Zoline on 7/14/17.
//  Copyright © 2017 MZ. All rights reserved.
//

import XCTest
@testable import 2D-Bounce


class 2D-BounceTests: XCTestCase {
    
//    var pA:CollisionParticle? = nil
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // test square func
    func testSqr() {
        let v: CGFloat = -5.0
        let expected: CGFloat = 25.0
        let result:CGFloat = 25 //sqr(v)
        XCTAssert( result == expected)
    }
    
    // test squared euclidian distance i.e. |w-v|^2
    func testDist2(){
       
    }
    
    func testPerformance() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
