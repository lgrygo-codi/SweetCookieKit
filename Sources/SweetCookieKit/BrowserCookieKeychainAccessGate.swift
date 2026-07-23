import Foundation

#if os(macOS)
/// Opt-in switch for disabling Keychain access in host apps.
public enum BrowserCookieKeychainAccessGate {
    enum SafeStoragePreflightStrategy {
        case secretProbe
        case metadataOnly
    }

    public nonisolated(unsafe) static var isDisabled: Bool = false

    /// Controls whether Chromium cookie decryption may promote a no-UI Keychain read to an interactive one.
    ///
    /// Interactive recovery remains the compatibility default. Hosts performing background work can suppress
    /// it for the duration of a specific import with ``withUserInteractionDisallowed(_:)``.
    @TaskLocal public static var isUserInteractionDisallowed = false

    @TaskLocal static var safeStoragePreflightStrategy: SafeStoragePreflightStrategy = .secretProbe

    /// Runs an operation that must not request user interaction from macOS Keychain.
    public static func withUserInteractionDisallowed<T>(_ operation: () throws -> T) rethrows -> T {
        try self.$isUserInteractionDisallowed.withValue(true) {
            try operation()
        }
    }

    /// Selects a Chromium Safe Storage alias using Keychain metadata before performing one secret read.
    ///
    /// This opt-in scope is intended for compatibility with Keychain items whose no-UI secret lookup still
    /// produces an authorization prompt. The default behavior remains a no-UI secret probe so silently readable
    /// items continue to work without invoking a host prompt handler.
    public static func withMetadataOnlySafeStoragePreflight<T>(_ operation: () throws -> T) rethrows -> T {
        try self.$safeStoragePreflightStrategy.withValue(.metadataOnly) {
            try operation()
        }
    }
}
#endif
