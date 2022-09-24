import Foundation
import simd

public struct Call: AnimationRig {

    private let callback: () -> Void

    public init(_ callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    public func create(at finishTime: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner {
        return Runner(callback: callback)
    }

    private struct Runner: AnimationRunner {
        private let callback: () -> Void

        init(callback: @escaping () -> Void ) {
            self.callback = callback
        }

        func apply(at time: Double) -> AnimationResult {
            self.callback()
            return .finishedNone(atTime: time)
        }
    }
}
