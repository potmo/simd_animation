import Foundation
import simd
import RealityKit

public struct CubicTranslation: AnimationRig {

    private let duration: Double
    private let startPositionProvider: () -> simd_float3
    private let intermediatePositionProvider1: () -> simd_float3
    private let intermediatePositionProvider2: () -> simd_float3
    private let endPositionProvider: () -> simd_float3
    private let easing: Easer

    public init(duration: Double,
                from evaluatedStartPosition: @escaping () -> simd_float3,
                via evaluatedIntermediatePosition1: @escaping () -> simd_float3,
                and evaluatedIntermediatePosition2: @escaping () -> simd_float3,
                to evaluatedEndPosition: @escaping () -> simd_float3,
                using easingMode: EasingMode = .easeInOut(.linear)) {
        self.easing = Easer(mode: easingMode)
        self.duration = duration
        self.startPositionProvider = evaluatedStartPosition
        self.endPositionProvider = evaluatedEndPosition
        self.intermediatePositionProvider1 = evaluatedIntermediatePosition1
        self.intermediatePositionProvider2 = evaluatedIntermediatePosition2
    }

    public init(duration: Double,
                from startPosition: simd_float3,
                via intermediatePosition1: simd_float3,
                and intermediatePosition2: simd_float3,
                to endPosition: simd_float3,
                using easingMode: EasingMode = .easeInOut(.linear)) {

        self.init(duration: duration,
                  from: {startPosition},
                  via: {intermediatePosition1},
                  and: {intermediatePosition2},
                  to: {endPosition},
                  using: easingMode)
    }

    public func create(at time: Double,
                       with position: simd_float3,
                       and orientation: simd_quatf) -> AnimationRunner {

        return Runner(startTime: time,
                      endTime: time + duration,
                      startPosition: startPositionProvider(),
                      via: intermediatePositionProvider1(),
                      and: intermediatePositionProvider2(),
                      endPosition: endPositionProvider(),
                      using: easing)
    }

    fileprivate struct Runner: AnimationRunner {
        private let startTime: Double
        private let endTime: Double
        private let startPosition: simd_float3
        private let endPosition: simd_float3
        private let intermediatePosition1: simd_float3
        private let intermediatePosition2: simd_float3
        private let easing: Easer

        init(startTime: Double,
             endTime: Double,
             startPosition: simd_float3,
             via intermediatePosition1: simd_float3,
             and intermediatePosition2: simd_float3,
             endPosition: simd_float3,
             using easing: Easer) {
            self.startTime = startTime
            self.endTime = endTime
            self.startPosition = startPosition
            self.endPosition = endPosition
            self.intermediatePosition1 = intermediatePosition1
            self.intermediatePosition2 = intermediatePosition2
            self.easing = easing
        }

        func apply(at time: Double, setPosition: (simd_float3) -> Void, setOrientation: (simd_quatf) -> Void) -> AnimationResult {

            let td = ((time - startTime) / (endTime - startTime)).clamped(to: 0...1)
            let t = Float(easing.map(td))

            let u = 1 - t
            let tt = t*t
            let uu = u*u
            let uuu = uu * u
            let ttt = tt * t

            let p0 = uuu * startPosition
            let p1 = 3 * t * uu * intermediatePosition1
            let p2 = 3 * tt * u * intermediatePosition2
            let p3 = ttt * endPosition

            let position = p0 + p1 + p2 + p3

            setPosition(position)

            if time >= endTime {
                return .finished(atTime: endTime)
            }else{
                return .running
            }
        }
    }
}
