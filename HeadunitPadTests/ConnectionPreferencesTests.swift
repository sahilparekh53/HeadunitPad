import XCTest
import Foundation

final class ConnectionPreferencesTests: XCTestCase {
    private func withPreferences(_ body: (ConnectionPreferences, UserDefaults) throws -> Void) rethrows {
        let name = "HeadunitPadTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: name) else { return XCTFail("Cannot create test defaults") }
        defer { defaults.removePersistentDomain(forName: name) }
        try body(ConnectionPreferences(defaults: defaults), defaults)
    }

    func testFirstLaunchDoesNotAutomaticallyConnectToAnUnknownPhone() {
        withPreferences { preferences, _ in
            XCTAssertTrue(preferences.automaticallyConnectsOnOpen)
            XCTAssertFalse(ReconnectPolicy.canResume(isActive: true, stoppedByUser: false, hasSessionIntent: false,
                automaticOnOpen: preferences.automaticallyConnectsOnOpen, hasConnectedBefore: preferences.hasConnectedBefore))
        }
    }

    func testSuccessfulPhoneSurvivesRelaunchAndCanBeForgotten() {
        withPreferences { preferences, defaults in
            let endpoint = SavedPhoneEndpoint(host: "192.168.43.1", port: 5277)
            preferences.rememberSuccessfulConnection(endpoint: endpoint)
            let relaunched = ConnectionPreferences(defaults: defaults)
            XCTAssertEqual(relaunched.lastEndpoint, endpoint)
            XCTAssertTrue(relaunched.hasConnectedBefore)
            relaunched.forgetPhone()
            XCTAssertNil(preferences.lastEndpoint)
            XCTAssertFalse(preferences.hasConnectedBefore)
        }
    }

    func testHelperConnectionDoesNotReuseAnOldDirectServer() {
        withPreferences { preferences, _ in
            preferences.rememberSuccessfulConnection(endpoint: SavedPhoneEndpoint(host: "192.168.1.8", port: 5277))
            preferences.rememberSuccessfulConnection(endpoint: nil)
            XCTAssertTrue(preferences.hasConnectedBefore)
            XCTAssertNil(preferences.lastEndpoint)
        }
    }

    func testInvalidOrCorruptSavedAddressFallsBackToDiscovery() {
        withPreferences { preferences, defaults in
            preferences.rememberSuccessfulConnection(endpoint: SavedPhoneEndpoint(host: "not an IP", port: 5277))
            XCTAssertNil(preferences.lastEndpoint)
            defaults.set(Data("broken json".utf8), forKey: "connection.last-successful-phone")
            XCTAssertNil(preferences.lastEndpoint)
            XCTAssertFalse(SavedPhoneEndpoint(host: "192.168.1.2", port: 0).isValid)
        }
    }

    func testStopAndBackgroundPreventAutomaticResume() {
        XCTAssertFalse(ReconnectPolicy.canResume(isActive: true, stoppedByUser: true, hasSessionIntent: true, automaticOnOpen: true, hasConnectedBefore: true))
        XCTAssertFalse(ReconnectPolicy.canResume(isActive: false, stoppedByUser: false, hasSessionIntent: true, automaticOnOpen: true, hasConnectedBefore: true))
        XCTAssertTrue(ReconnectPolicy.canResume(isActive: true, stoppedByUser: false, hasSessionIntent: true, automaticOnOpen: false, hasConnectedBefore: false))
        XCTAssertTrue(ReconnectPolicy.canResume(isActive: true, stoppedByUser: false, hasSessionIntent: false, automaticOnOpen: true, hasConnectedBefore: true))
    }

    func testAutomaticConnectionOptOutPersistsAndRetryDelayIsBounded() {
        withPreferences { preferences, defaults in
            preferences.automaticallyConnectsOnOpen = false
            XCTAssertFalse(ConnectionPreferences(defaults: defaults).automaticallyConnectsOnOpen)
        }
        XCTAssertEqual((0...5).map { ReconnectPolicy.delay(attempt: $0) }, [2, 4, 8, 16, 20, 20])
        XCTAssertEqual(ReconnectPolicy.delay(attempt: 1000), 20)
    }
}
