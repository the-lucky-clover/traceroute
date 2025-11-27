import Foundation

/// App configuration for update and versioning
public struct AppConfiguration: Codable {
    public static let current = AppConfiguration(
        version: "1.0.0",
        buildNumber: 1,
        updateURL: URL(string: "https://github.com/the-lucky-clover/traceroute/releases"),
        modulesVersion: "1.0.0"
    )
    
    public let version: String
    public let buildNumber: Int
    public let updateURL: URL?
    public let modulesVersion: String
    
    public init(version: String, buildNumber: Int, updateURL: URL?, modulesVersion: String) {
        self.version = version
        self.buildNumber = buildNumber
        self.updateURL = updateURL
        self.modulesVersion = modulesVersion
    }
}

/// Protocol for modular components that can be updated
public protocol UpdatableModule {
    var moduleIdentifier: String { get }
    var moduleVersion: String { get }
    func checkForUpdates() async throws -> Bool
}
