import XCTest

final class DashboardUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .landscapeLeft
        app = XCUIApplication()
        app.launch()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allow = springboard.alerts.buttons["Allow"].firstMatch
        if allow.waitForExistence(timeout: 4) { allow.tap() }
    }

    override func tearDownWithError() throws { app.terminate() }

    func testDashboardFitsLandscapeAndPhoneAddressFormIsAccessible() {
        let connect = app.buttons["Connect to Android Auto"]
        let address = app.buttons["Enter phone IP address"]
        let settings = app.buttons["Connection and display settings"]
        XCTAssertTrue(connect.waitForExistence(timeout: 8))
        XCTAssertTrue(address.isHittable)
        XCTAssertGreaterThanOrEqual(settings.frame.width, 44)
        let landscape = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            self.app.frame.width > self.app.frame.height
        }, object: nil)
        wait(for: [landscape], timeout: 5)
        XCTAssertLessThanOrEqual(address.frame.maxY, app.frame.maxY)
        address.tap()
        XCTAssertTrue(app.alerts["Enter IP Address"].waitForExistence(timeout: 3))
        app.alerts.buttons["Cancel"].tap()
        XCTAssertTrue(connect.isHittable)
        let attachment = XCTAttachment(screenshot: XCUIDevice.shared.screenshot())
        attachment.name = "HeadunitPad landscape dashboard"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testInvalidPhoneAddressShowsFeedbackWithoutStartingAConnection() {
        let address = app.buttons["Enter phone IP address"]
        XCTAssertTrue(address.waitForExistence(timeout: 8))
        address.tap()
        let field = app.alerts.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 3))
        field.tap()
        field.typeText("999.999.999.999")
        app.alerts.buttons["Connect"].tap()
        XCTAssertTrue(app.staticTexts["Enter a valid phone Wi-Fi address, such as 192.168.1.5."].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Connect to Android Auto"].isHittable)
    }
}
