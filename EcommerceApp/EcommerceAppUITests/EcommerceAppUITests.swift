//
//  EcommerceAppUITests.swift
//  EcommerceAppUITests
//
//  Created by Russel Rajitha  on 2026-04-02.
//

import XCTest

final class EcommerceAppUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testTabBarAllButtonsVisible() throws {
        XCTAssertTrue(app.buttons["Shop"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Cart"].exists)
        XCTAssertTrue(app.buttons["Notifications"].exists)
        XCTAssertTrue(app.buttons["Profile"].exists)
    }

    // MARK: - Default Tab
    func testDefaultTabIsShop() throws {
        XCTAssertTrue(app.navigationBars["Shop"].waitForExistence(timeout: 5))
    }

    // MARK: - Tab Switching
    func testSwitchToCartTab() throws {
        XCTAssertTrue(app.buttons["Cart"].waitForExistence(timeout: 5))
        app.buttons["Cart"].tap()
        let predicate = NSPredicate(format: "identifier BEGINSWITH 'Cart'")
        XCTAssertTrue(app.navigationBars.matching(predicate).firstMatch.waitForExistence(timeout: 5))
    }

    func testSwitchToNotificationsTab() throws {
        XCTAssertTrue(app.buttons["Notifications"].waitForExistence(timeout: 5))
        app.buttons["Notifications"].tap()
        XCTAssertTrue(app.navigationBars["Notifications"].waitForExistence(timeout: 5))
    }

    func testSwitchToProfileTab() throws {
        XCTAssertTrue(app.buttons["Profile"].waitForExistence(timeout: 5))
        app.buttons["Profile"].tap()
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
    }

    func testSwitchBackToShopFromProfile() throws {
        XCTAssertTrue(app.buttons["Profile"].waitForExistence(timeout: 5))
        app.buttons["Profile"].tap()
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        app.buttons["Shop"].tap()
        XCTAssertTrue(app.navigationBars["Shop"].waitForExistence(timeout: 5))
    }

    // MARK: - Full Cycle

    func testTabSwitchFullCycle() throws {
        let steps: [(button: String, navPrefix: String)] = [
            ("Cart", "Cart"),
            ("Notifications", "Notifications"),
            ("Profile", "Profile"),
            ("Shop", "Shop"),
        ]

        XCTAssertTrue(app.buttons["Shop"].waitForExistence(timeout: 5))

        for (button, prefix) in steps {
            app.buttons[button].tap()
            let pred = NSPredicate(format: "identifier BEGINSWITH '\(prefix)'")
            XCTAssertTrue(
                app.navigationBars.matching(pred).firstMatch.waitForExistence(timeout: 5),
                "Navigation bar with prefix '\(prefix)' not found after tapping '\(button)'"
            )
        }
    }

    // MARK: - Performance
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
