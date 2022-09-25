import Foundation
import simd

struct Idle: AnimationRig {

    func create() -> AnimationRunner {
        return Runner()
    }
    func create(at time: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner {
        return Runner()
    }

    private struct Runner: AnimationRunner {
        func apply(at time: Double, setPosition: (simd_float3) -> Void, setOrientation: (simd_quatf) -> Void) -> AnimationResult {
            return .finished(atTime: time)
        }
    }
}
