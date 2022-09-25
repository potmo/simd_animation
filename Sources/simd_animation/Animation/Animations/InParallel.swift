import Foundation
import simd

public struct InParallel: AnimationRig {

    let rigs: [AnimationRig]
    public init(rigs: [AnimationRig]) {
        self.rigs = rigs
    }

    public init(@AnimationArrayBuilder builder: () -> [AnimationRig]) {
        self.rigs = builder()
    }

    public func create(at time: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner {
        let runners = rigs.map{ rig in
            rig.create(at: time, with: position, and: orientation)
        }

        return Runner(runners: runners)
    }


    private struct Runner: AnimationRunner {

        private let runners: [AnimationRunner]


        init(runners: [AnimationRunner]) {
            self.runners = runners
        }

        func apply(at time: Double, setPosition: (simd_float3) -> Void, setOrientation: (simd_quatf) -> Void) -> AnimationResult {

            if runners.isEmpty {
                return .finished(atTime: time)
            }

            var lastKnownPosition: simd_float3?
            var lastKnownOrientation: simd_quatf?

            let results = runners.map{ runner in
                return runner.apply(at: time,
                                    setPosition: { position in lastKnownPosition = position},
                                    setOrientation: {orienation in lastKnownOrientation = orienation})
            }

            if let lastKnownPosition {
                setPosition(lastKnownPosition)
            }

            if let lastKnownOrientation {
                setOrientation(lastKnownOrientation)
            }


            let allFinished = results.allSatisfy(\.isFinished)

            if allFinished {

                guard let lastFinishTime = results.map(\.finishingTime).compactMap({$0}).max() else {
                    fatalError("there should be a maximum finish time")
                }

                return .finished(atTime: lastFinishTime)
            }

            return .running


        }
    }

}
