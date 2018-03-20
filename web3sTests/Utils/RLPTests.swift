//
//  RLPTests.swift
//  web3sTests
//
//  Created by Julien Niset on 23/02/2018.
//  Copyright © 2018 Argent Labs. All rights reserved.
//

import XCTest
@testable import web3swift
import BigInt

class RLPTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEncodeEmptyString() {
        let input = ""
        let encoded = RLP.encode(input)!
        
        XCTAssertTrue(encoded.hexString == "0x80")
    }
    
    func testEncodeString() {
        let input = "dog"
        var encoded = RLP.encode(input)!
        
        XCTAssertEqual(encoded.count, 4)
        
        XCTAssertEqual(encoded[0], 131)
        XCTAssertEqual(encoded[1], 100)
        XCTAssertEqual(encoded[2], 111)
        XCTAssertEqual(encoded[3], 103)
        
        XCTAssertTrue(encoded.hexString == "0x83646f67")
    }
    
    func testEncodeLongString() {
        let input = "zoo255zoo255zzzzzzzzzzzzssssssssssssssssssssssssssssssssssssssssssssss"
        var encoded = RLP.encode(input)!
        
        XCTAssertEqual(encoded.count, 72)
        
        XCTAssertEqual(encoded[0], 184)
        XCTAssertEqual(encoded[1], 70)
        XCTAssertEqual(encoded[2], 122)
        XCTAssertEqual(encoded[3], 111)
        XCTAssertEqual(encoded[12], 53)
    }

    func testEncodeList() {
        let input = ["dog", "god", "cat"]
        var encoded = RLP.encode(input)!
        
        XCTAssertEqual(encoded.count, 13)
        
        XCTAssertEqual(encoded[0], 204)
        XCTAssertEqual(encoded[1], 131)
        XCTAssertEqual(encoded[11], 97)
        XCTAssertEqual(encoded[12], 116)
    }
    
    func testEncodeInt() {
        let input = 15
        var encoded = RLP.encode(input)!
        
        XCTAssertEqual(encoded.count, 1)
        XCTAssertEqual(encoded[0], 15)
    }
    
    func testEncodeLongInt() {
        let input = 1024
        var encoded = RLP.encode(input)!
        
        XCTAssertEqual(encoded.count, 3)
        XCTAssertEqual(encoded[0], 130)
        XCTAssertEqual(encoded[1], 4)
        XCTAssertEqual(encoded[2], 0)
    }
    
    
    func testEncodeEther() {
        let input = Ether(gwei: 42)
        let encoded = RLP.encode(input)!
        XCTAssertEqual(encoded.hexString, "0x8509c7652400")
    }
    
    func testEncodeBigUInt() {
        let input = BigUInt("9223372036854775807")!
        let encoded = RLP.encode(input)!
        XCTAssertEqual(encoded.hexString, "0x887fffffffffffffff")
    }
    
    func testEncodeZero() {
        let input = 0
        let encoded = RLP.encode(input)!
        XCTAssertEqual(encoded.hexString, "0x80")
    }
    
    func testEncodeEncodedZero() {
        let input = "0x00"
        let encoded = RLP.encode(input)!
        XCTAssertEqual(encoded.hexString, "0x00")
    }
    
    func testEncodeNestedList() {
        
        let input = [
            [],
            [
                []
            ],
            [
                [],
                [
                    []
                ]
            ]
        ]
        
        let encoded = RLP.encode(input)!
        let expected = Data(bytes: [0xc7, 0xc0, 0xc1, 0xc0, 0xc3, 0xc0, 0xc1, 0xc0])
        
        XCTAssertEqual(expected, encoded)
    }
    
    func testOfficalTests() {
        let url = Bundle(for: type(of: self)).url(forResource: "rlptests", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: data) as? [String: [String: Any]]
        
        json?.forEach({ (key, value) in
            var input = value["in"] as Any
            let output = value["out"] as! String
            
            if let inputStr = input as? String, inputStr.count > 0, let numericString = BigUInt(inputStr) {
                input = numericString
            }
            
            let encoded = RLP.encode(input)!
            let expected = output.lowercased()
            
            XCTAssertEqual(expected, encoded.hexString.noHexPrefix, "\(key) failed for \(input)")
        })
    }
    
}
