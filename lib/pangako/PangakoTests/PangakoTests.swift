//
//  PangakoTests.swift
//  PangakoTests
//
//  Created by Mounir Ybanez on 2/14/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import XCTest
@testable import Pangako

class PangakoTests: XCTestCase {
    
    func testPangakoWithOneThenAndCallResolve() {
        let exp = expectation(description: "testPangakoWithOneThenAndCallResolve")
        let pangako = Pangako<String> { resolve, reject in
            resolve("hello")
        }
        pangako
            .then { fulfillString($0, exp) }
        wait(for: [exp], timeout: 5.0)
    }
    
    func testPangakoWithOneThenAndCatchAndCallResolve() {
        let exp = expectation(description: "testPangakoWithOneThenAndCatchAndCallResolve")
        let pangako = Pangako<String> { resolve, reject in
            resolve("hello")
        }
        pangako
            .then { fulfillString($0, exp) }
            .catch { failError($0) }
        wait(for: [exp], timeout: 5.0)
    }
    
    func testPangakoWithOneThenAndCatchAndCallReject() {
        let exp = expectation(description: "testPangakoWithOneThenAndCatchAndCallReject")
        let pangako = Pangako<String> { resolve, reject in
            reject(sampleError)
        }
        pangako
            .then { failString($0) }
            .catch { fulfillError($0, exp) }
        wait(for: [exp], timeout: 5.0)
    }
    
    func testPangakoWithMultipleThen() {
        let exp = expectation(description: "testPangakoWithMultipleThen")
        let pangako = Pangako<String> { resolve, reject in
            resolve("hello")
        }
        pangako
            .then { print($0) }
            .then { 1 }
            .then { fulfillInt($0, exp) }
        wait(for: [exp], timeout: 5.0)
    }
    
    func testPangakoThenWithAsync() {
        let exp = expectation(description: "testPangakoThenWithAsync")
        let pangako = Pangako<String> { resolve, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                resolve("hello")
            })
        }
        pangako
            .then { print($0) }
            .then { 1 }
            .then { fulfillInt($0, exp) }
        wait(for: [exp], timeout: 5.0)
    }
    
    func testPangakoCatchOnThrow() {
        let exp = expectation(description: "testPangakoCatchOnThrow")
        let pangako = Pangako<String> { resolve, reject in
            throw sampleError
        }
        pangako
            .catch { fulfillError($0, exp) }
        wait(for: [exp], timeout: 5.0)
    }
    
    func testPangakoThatThrowsHavingOneThenAndCatch() {
        let exp = expectation(description: "testPangakoThatThrowsHavingOneThenAndCatch")
        let pangako = Pangako<String> { resolve, reject in
            throw sampleError
        }
        pangako
            .then { print($0) }
            .catch { fulfillError($0, exp) }
        wait(for: [exp], timeout: 5.0)
    }
    
    func testPangakoWithMultipleThenAndOneCatchAtTheEnd() {
        let exp = expectation(description: "testPangakoWithMultipleThenAndOneCatchAtTheEnd")
        let pangako = Pangako<String> { resolve, reject in
            resolve("hello")
        }
        pangako
            .then { print($0) }
            .then { 8 }
            .then { print($0) }
            .then { throw sampleError }
            .catch { fulfillError($0, exp) }
        wait(for: [exp], timeout: 5.0)
    }
    
    func testPangakoWithMultipleThenAndCatchAtTheMiddle() {
        let exp = expectation(description: "testPangakoThenWithCatchAtTheMiddle")
        let pangako = Pangako<String> { resolve, reject in
            resolve("hello")
        }
        pangako
            .then { print($0) }
            .then { throw sampleError }
            .then { print($0) }
            .catch { fulfillError($0, exp) }
            .then { failAny() }
            .then { failAny() }
        wait(for: [exp], timeout: 5.0)
    }
    
    func testPangakoWithThenMutatinValueOfTypePangakoAndCallResolve() {
        let exp = expectation(description: "testPangakoThenMutatinValueOfTypePangako")
        let returnPangakoInt: (String) -> Pangako<Int> = { string in
            return Pangako<Int> { resolve, reject in
                resolve(4)
            }
        }
        let assertPangakoInt: (Int) -> Void = { int in
            XCTAssertEqual(int, 4)
            fulfillInt(int, exp)
        }
        let pangako = Pangako<String> { resolve, reject in
            resolve("hello")
        }
        pangako
            .then { returnPangakoInt($0) }
            .then { assertPangakoInt($0) }
        wait(for: [exp], timeout: 5.0)
    }
    
    func testPangakoWithThenMutatinValueOfTypePangakoAndCallReject() {
        let exp = expectation(description: "testPangakoWithThenMutatinValueOfTypePangakoAndCallReject")
        let returnPangakoInt: (String) -> Pangako<Int> = { string in
            return Pangako<Int> { resolve, reject in
                reject(sampleError)
            }
        }
        let pangako = Pangako<String> { resolve, reject in
            resolve("hello")
        }
        pangako
            .then { returnPangakoInt($0) }
            .then { failInt($0) }
            .catch { fulfillError($0, exp) }
        wait(for: [exp], timeout: 5.0)
    }
}
