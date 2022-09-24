import Foundation
import simd

struct Idle: AnimationRig {
    func create(at time: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner {
        return Runner()
    }

    private struct Runner: AnimationRunner {
        func apply(to position: simd_float3, and  orientation: simd_quatf, with time: Double) -> AnimationResult {
            return .finished(position: position, orientaion: orientation, atTime: time)
        }
    }
}
