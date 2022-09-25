import Foundation
import simd

struct RunningAnimation: AnimationRig {

    private let runner: AnimationRunner

    public init(runner: AnimationRunner) {
        self.runner = runner
    }

    public func create(at finishTime: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner {
        return runner
    }
}
