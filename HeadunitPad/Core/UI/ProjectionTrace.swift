import Foundation

/// Keep high-frequency formatting and console I/O out of release projection sessions.
nonisolated func projectionTrace(_ message: @autoclosure () -> String) {
#if DEBUG
    print(message())
#endif
}
