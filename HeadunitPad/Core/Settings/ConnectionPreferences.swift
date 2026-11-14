import Foundation
import Network

nonisolated struct SavedPhoneEndpoint: Codable, Equatable, Sendable {
    let host: String
    let port: UInt16

    var isValid: Bool { IPv4Address(host) != nil && port > 0 }
}

nonisolated final class ConnectionPreferences {
    private let defaults: UserDefaults
    private let endpointKey = "connection.last-successful-phone"
    private let connectedKey = "connection.has-connected-before"
    private let automaticKey = "connection.automatic-on-open"

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    var automaticallyConnectsOnOpen: Bool {
        get { defaults.object(forKey: automaticKey) == nil || defaults.bool(forKey: automaticKey) }
        set { defaults.set(newValue, forKey: automaticKey) }
    }

    var hasConnectedBefore: Bool { defaults.bool(forKey: connectedKey) }

    var lastEndpoint: SavedPhoneEndpoint? {
        guard let data = defaults.data(forKey: endpointKey),
              let endpoint = try? JSONDecoder().decode(SavedPhoneEndpoint.self, from: data),
              endpoint.isValid else { return nil }
        return endpoint
    }

    func rememberSuccessfulConnection(endpoint: SavedPhoneEndpoint?) {
        defaults.set(true, forKey: connectedKey)
        if let endpoint, endpoint.isValid, let data = try? JSONEncoder().encode(endpoint) {
            defaults.set(data, forKey: endpointKey)
        } else {
            defaults.removeObject(forKey: endpointKey)
        }
    }

    func forgetPhone() {
        defaults.removeObject(forKey: endpointKey)
        defaults.removeObject(forKey: connectedKey)
    }
}

nonisolated enum ReconnectPolicy {
    static func canResume(isActive: Bool, stoppedByUser: Bool, hasSessionIntent: Bool,
                          automaticOnOpen: Bool, hasConnectedBefore: Bool) -> Bool {
        isActive && !stoppedByUser && (hasSessionIntent || (automaticOnOpen && hasConnectedBefore))
    }

    static func delay(attempt: Int) -> TimeInterval {
        min(20, 2 * pow(2, Double(min(4, max(0, attempt)))))
    }
}
