import Foundation
import simd

public struct Delay: AnimationRig {

    private let duration: Double
    public init(duration: Double) {
        self.duration = duration
    }

    public func create(at time: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner {
        return Runner(startTime: time, endTime: time + duration)
    }

    private struct Runner: AnimationRunner {
        private let startTime: Double
        private let endTime: Double

        init(startTime: Double, endTime: Double) {
            self.startTime = startTime
            self.endTime = endTime
        }

        func apply(to position: simd_float3, and  orientation: simd_quatf, with time: Double) -> AnimationResult {
            let t = ((time - startTime) / (endTime - startTime)).clamped(to: 0...1)

            if t >= 1 {
                return .finished(position: position, orientaion: orientation, atTime: time)
            }else{
                return .running(position: position, orientaion: orientation)
            }
        }
    }
}
