import Foundation
import simd
import RealityKit

public struct LinearTranslation: AnimationRig {

    private let duration: Double
    private let startPositionProvider: () -> simd_float3
    private let endPositionProvider: () -> simd_float3
    private let easing: Easer

    public init(duration: Double,
                from evaluatedStartPosition: @escaping () -> simd_float3,
                to evaluatedEndPosition: @escaping () -> simd_float3,
                using easingMode: EasingMode = .easeInOut(.linear)) {
        self.easing = Easer(mode: easingMode)
        self.duration = duration
        self.startPositionProvider = evaluatedStartPosition
        self.endPositionProvider = evaluatedEndPosition
    }

    public init(duration: Double,
                from startPosition: simd_float3,
                to endPosition: simd_float3,
                using easingMode: EasingMode = .easeInOut(.linear)) {
        self.init(duration: duration, from: {return startPosition}, to: {return endPosition}, using: easingMode)
    }

    public func create(at time: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner {
        return Runner(startTime: time,
                      endTime: time + duration,
                      startPosition: startPositionProvider(),
                      endPosition: endPositionProvider(),
                      using: easing)
    }

    fileprivate struct Runner: AnimationRunner {
        private let startTime: Double
        private let endTime: Double
        private let startPosition: simd_float3
        private let endPosition: simd_float3
        private let easing: Easer

        init(startTime: Double, endTime: Double, startPosition: simd_float3, endPosition: simd_float3, using easing: Easer) {
            self.startTime = startTime
            self.endTime = endTime
            self.startPosition = startPosition
            self.endPosition = endPosition
            self.easing = easing
        }

        func apply(at time: Double, setPosition: (simd_float3) -> Void, setOrientation: (simd_quatf) -> Void) -> AnimationResult {
            
            let t = ((time - startTime) / (endTime - startTime)).clamped(to: 0...1)
            let et = easing.map(t)
            let position = simd_mix(startPosition, endPosition, [Float(et),Float(et),Float(et)])

            setPosition(position)
            
            if time >= endTime {
                return .finished(atTime: time)
            }else{
                return .running
            }
        }
    }
}

public struct LinearRelativeToCurrentPositionTranslation: AnimationRig {

    private let duration: Double
    private let endPositionProvider: () -> simd_float3
    private let easing: Easer

    public init(duration: Double,
                to endPosition: simd_float3,
                using easingMode: EasingMode = .easeInOut(.linear)) {
        self.init(duration: duration, to: {endPosition}, using: easingMode)
    }

    public init(duration: Double,
                to endPositionProvider: @escaping () -> simd_float3,
                using easingMode: EasingMode = .easeInOut(.linear)) {
        self.easing = Easer(mode: easingMode)
        self.duration = duration
        self.endPositionProvider = endPositionProvider
    }

    public func create(at time: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner {
        return LinearTranslation.Runner(startTime: time,
                                        endTime: time + duration,
                                        startPosition: position,
                                        endPosition: endPositionProvider(),
                                        using: easing)
    }
}


