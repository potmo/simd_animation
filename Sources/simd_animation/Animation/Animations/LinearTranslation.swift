import Foundation
import simd
import RealityKit

public struct LinearTranslation: AnimationRig {

    private let duration: Double
    private let startPositionProvider: (() -> simd_float3)?
    private let endPositionProvider: () -> simd_float3

    public init(duration: Double,
         from evaluatedStartPosition: @escaping () -> simd_float3,
         to evaluatedEndPosition: @escaping () -> simd_float3) {
        self.duration = duration
        self.startPositionProvider = evaluatedStartPosition
        self.endPositionProvider = evaluatedEndPosition
    }

    public init(duration: Double,
         from startPosition: simd_float3,
         to endPosition: simd_float3) {
        self.init(duration: duration, from: {return startPosition}, to: {return endPosition})
    }

    public init(duration: Double,
                to endPosition: simd_float3) {
        self.duration = duration
        self.startPositionProvider = nil
        self.endPositionProvider = {endPosition}
    }

    public init(duration: Double,
                to endPositionProvider: @escaping () -> simd_float3) {
        self.duration = duration
        self.startPositionProvider = nil
        self.endPositionProvider = endPositionProvider
    }

    public func create(at time: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner {
        return Runner(startTime: time,
                      endTime: time + duration,
                      startPosition: startPositionProvider?() ?? position,
                      endPosition: endPositionProvider())
    }

    private struct Runner: AnimationRunner {
        private let startTime: Double
        private let endTime: Double
        private let startPosition: simd_float3
        private let endPosition: simd_float3

        init(startTime: Double, endTime: Double, startPosition: simd_float3, endPosition: simd_float3) {
            self.startTime = startTime
            self.endTime = endTime
            self.startPosition = startPosition
            self.endPosition = endPosition
        }

        func apply(to position: simd_float3, and  orientation: simd_quatf, with time: Double) -> AnimationResult {
            let t = ((time - startTime) / (endTime - startTime)).clamped(to: 0...1)
            let newPosition = simd_mix(startPosition, endPosition, [Float(t),Float(t),Float(t)])

            if time >= endTime {
                return .finished(position: newPosition, orientaion: orientation, atTime: endTime)
            }else{
                return .running(position: newPosition, orientaion: orientation)
            }
        }
    }
}


