import Foundation
import simd
import RealityKit

public struct LinearRotation: AnimationRig {

    private let duration: Double
    private let startOrientationProvider: (() -> simd_quatf)?
    private let endOrientationProvider: () -> simd_quatf
    private let easing: Easer

    public init(duration: Double,
                from evaluatedStartOrientation: @escaping () -> simd_quatf,
                to evaluatedEndOrientation: @escaping () -> simd_quatf,
                using easingMode: EasingMode = .easeInOut(.linear)) {
        self.easing = Easer(mode: easingMode)
        self.duration = duration
        self.startOrientationProvider = evaluatedStartOrientation
        self.endOrientationProvider = evaluatedEndOrientation
    }

    public init(duration: Double,
                from startOrientatin: simd_quatf,
                to endOrientation: simd_quatf,
                using easingMode: EasingMode = .easeInOut(.linear)) {
        self.init(duration: duration, from: {return startOrientatin}, to: {return endOrientation}, using: easingMode)
    }

    public init(duration: Double,
                to endOrientation: simd_quatf,
                using easingMode: EasingMode = .easeInOut(.linear)) {
        self.init(duration: duration, to: {return endOrientation}, using: easingMode)
    }

    public init(duration: Double,
                to evaluatedEndOrientation: @escaping () -> simd_quatf,
                using easingMode: EasingMode = .easeInOut(.linear)) {
        self.easing = Easer(mode: easingMode)
        self.duration = duration
        self.startOrientationProvider = nil
        self.endOrientationProvider = evaluatedEndOrientation
    }


    public func create(at time: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner {

        let startOrientation = startOrientationProvider?() ?? orientation
        let endOrientation = endOrientationProvider()
        return Runner(startTime: time,
                      endTime: time + duration,
                      startOrientation: startOrientation,
                      endOrientation: endOrientation,
                      using: easing)
    }

    private struct Runner: AnimationRunner {
        private let startTime: Double
        private let endTime: Double
        private let startOrientation: simd_quatf
        private let endOrientation: simd_quatf
        private let easing: Easer

        init(startTime: Double, endTime: Double, startOrientation: simd_quatf, endOrientation: simd_quatf, using easing: Easer) {
            self.easing = easing
            self.startTime = startTime
            self.endTime = endTime
            self.startOrientation = startOrientation
            self.endOrientation = endOrientation
        }

        func apply(at time: Double, setPosition: (simd_float3) -> Void, setOrientation: (simd_quatf) -> Void) -> AnimationResult {
            let t = ((time - startTime) / (endTime - startTime)).clamped(to: 0...1)
            let te = easing.map(t)

            //TODO: add possibility to rotate shortest and longest
            let orientation = simd_slerp(startOrientation, endOrientation, Float(te))
            setOrientation(orientation)

            if time >= endTime {
                return .finished(atTime: endTime)
            }else{
                return .running
            }
        }
    }
}


