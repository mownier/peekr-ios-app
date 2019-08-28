//
//  TestHelpers.swift
//  PangakoTests
//
//  Created by Mounir Ybanez on 2/14/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import XCTest

var sampleError: Error {
    return NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sample error"])
}

func fail<A>() -> (A) -> Void {
    return { A in
        XCTFail()
    }
}

func failAny(_ a: Any? = nil) -> Void {
    return fail()(a)
}

func failError(_ a: Error? = nil) -> Void {
    return fail()(a)
}

func failString(_ a: String? = nil) -> Void {
    return fail()(a)
}

func failDouble(_ a: Double? = nil) -> Void {
    return fail()(a)
}

func failInt(_ a: Int? = nil) -> Void {
    return fail()(a)
}

func fulfill<A>(_ e: XCTestExpectation) -> (A) -> Void {
    return { A in
        e.fulfill()
    }
}

func fulfillString(_ a: String? = nil, _ e: XCTestExpectation) -> Void {
    return fulfill(e)(a)
}

func fulfillError(_ a: Error? = nil, _ e: XCTestExpectation) -> Void {
    return fulfill(e)(a)
}

func fulfillInt(_ a: Int? = nil, _ e: XCTestExpectation) -> Void {
    return fulfill(e)(a)
}
