import Foundation
import simd
import RealityKit

public struct LinearRotation: AnimationRig {

    private let duration: Double
    private let startOrientationProvider: () -> simd_quatf
    private let endOrientationProvider: () -> simd_quatf

    public init(duration: Double,
         from evaluatedStartOrientation: @escaping () -> simd_quatf,
         to evaluatedEndOrientation: @escaping () -> simd_quatf) {
        self.duration = duration
        self.startOrientationProvider = evaluatedStartOrientation
        self.endOrientationProvider = evaluatedEndOrientation
    }

    public init(duration: Double,
         from startOrientatin: simd_quatf,
         to endOrientation: simd_quatf) {
        self.init(duration: duration, from: {return startOrientatin}, to: {return endOrientation})
    }


    public func create(at time: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner {
        return Runner(startTime: time,
                      endTime: time + duration,
                      startOrientation: startOrientationProvider(),
                      endOrientation: endOrientationProvider())
    }

    private struct Runner: AnimationRunner {
        private let startTime: Double
        private let endTime: Double
        private let startOrientation: simd_quatf
        private let endOrientation: simd_quatf

        init(startTime: Double, endTime: Double, startOrientation: simd_quatf, endOrientation: simd_quatf) {
            self.startTime = startTime
            self.endTime = endTime
            self.startOrientation = startOrientation
            self.endOrientation = endOrientation
        }

        func apply(at time: Double) -> AnimationResult {
            let t = ((time - startTime) / (endTime - startTime)).clamped(to: 0...1)
            let orientation = simd_slerp(startOrientation, endOrientation, Float(t))

            if time >= endTime {
                return .finishedOrientation(orientation: orientation, atTime: endTime)
            }else{
                return .runningOrientation(orientation: orientation)
            }
        }
    }
}


