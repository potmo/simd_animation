import Foundation
import simd

public struct While: AnimationRig {

    private let evaluator: () -> Bool

    public init(_ isDoneEvaluator: @escaping () -> Bool) {
        self.evaluator = isDoneEvaluator
    }

    public func create(at time: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner {
        return Runner(callback: evaluator)
    }

    private struct Runner: AnimationRunner {
        private let evaluator: () -> Bool

        init(callback: @escaping () -> Bool ) {
            self.evaluator = callback
        }

        func apply(at time: Double, setPosition: (simd_float3) -> Void, setOrientation: (simd_quatf) -> Void) -> AnimationResult {
            if self.evaluator() {
                return .finished(atTime: time)
            }else {
                return .running
            }

        }
    }
}
