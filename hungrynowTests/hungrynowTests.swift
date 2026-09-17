//
//  hungrynowTests.swift
//  hungrynowTests
//
//  Created by Asa Teknologi on 02/09/26.
//

import XCTest
@testable import hungrynow

final class hungrynowTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCompactCountFormatting() throws {
        // Under 1,000 stays as plain integer
        XCTAssertEqual(FactFormatter.compactCount(50), "50")
        XCTAssertEqual(FactFormatter.compactCount(999), "999")

        // 1,000 -> "1k" (no unnecessary trailing zeros)
        XCTAssertEqual(FactFormatter.compactCount(1000), "1k")

        // 1,500 -> 1 decimal place ("1.5k" or "1,5k" depending on decimal separator)
        let formatted1500 = FactFormatter.compactCount(1500)
        XCTAssertTrue(formatted1500 == "1.5k" || formatted1500 == "1,5k")

        // 1,530 -> 2 decimal places ("1.53k" or "1,53k")
        let formatted1530 = FactFormatter.compactCount(1530)
        XCTAssertTrue(formatted1530 == "1.53k" || formatted1530 == "1,53k")

        // 1,534 -> maximum 2 decimal places ("1.53k" or "1,53k")
        let formatted1534 = FactFormatter.compactCount(1534)
        XCTAssertTrue(formatted1534 == "1.53k" || formatted1534 == "1,53k")

        // 10,000 -> "10k"
        XCTAssertEqual(FactFormatter.compactCount(10000), "10k")
    }

    func testRatingFormattingWithReviewCount() throws {
        // Without count
        let withoutCount = FactFormatter.rating(4.7)
        XCTAssertTrue(withoutCount == "4.7" || withoutCount == "4,7")

        // With nil count
        let withNil = FactFormatter.rating(4.7, count: nil)
        XCTAssertTrue(withNil == "4.7" || withNil == "4,7")

        // With zero count
        let withZero = FactFormatter.rating(4.7, count: 0)
        XCTAssertTrue(withZero == "4.7" || withZero == "4,7")

        // With count (e.g. 1530 reviews)
        let withCount = FactFormatter.rating(4.7, count: 1530)
        XCTAssertTrue(withCount == "4.7 (1.53k)" || withCount == "4,7 (1,53k)")
    }

}
