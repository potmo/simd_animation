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

        func apply(at time: Double) -> AnimationResult {
            if time >= endTime {
                return .finishedNone(atTime: time)
            }else{
                return .runningNone
            }
        }
    }
}
