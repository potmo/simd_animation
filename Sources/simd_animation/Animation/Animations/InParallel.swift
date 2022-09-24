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

        func apply(at time: Double) -> AnimationResult {

            if runners.isEmpty {
                return .finishedNone(atTime: time)
            }

            var lastKnownPosition: simd_float3?
            var lastKnownOrientation: simd_quatf?

            let results = runners.map{ runner in
                return runner.apply(at: time)
            }

            results.forEach{result in
                lastKnownPosition = result.position ?? lastKnownPosition
                lastKnownOrientation = result.orientation ?? lastKnownOrientation
            }

            let allFinished = results.allSatisfy(\.isFinished)

            if allFinished {

                guard let lastFinishTime = results.map(\.finishingTime).compactMap({$0}).max() else {
                    fatalError("there should be a maximum finish time")
                }

                if let lastKnownPosition, let lastKnownOrientation {
                    return .finishedPositionOrientation(position: lastKnownPosition,
                                                        orientation: lastKnownOrientation,
                                                        atTime: lastFinishTime)
                } else if let lastKnownPosition {
                    return .finishedPosition(position: lastKnownPosition, atTime: lastFinishTime)
                } else if let lastKnownOrientation {
                    return .finishedOrientation(orientation: lastKnownOrientation, atTime: lastFinishTime)
                }else {
                    return .finishedNone(atTime: lastFinishTime)
                }
            }

            if let lastKnownPosition, let lastKnownOrientation {
                return .runningPositionOrientation(position: lastKnownPosition,
                                                    orientation: lastKnownOrientation)
            } else if let lastKnownPosition {
                return .runningPosition(position: lastKnownPosition)
            } else if let lastKnownOrientation {
                return .runningOrientation(orientation: lastKnownOrientation)
            }else {
                return .runningNone
            }


        }
    }

}


fileprivate extension Array {
    func sweep<Output, Intermediate>(_ initial: Intermediate, transformer: (Intermediate, Element)-> (Intermediate, Output)) -> (Intermediate,[Output]) {

        var transformedElements: [Output] = []
        transformedElements.reserveCapacity(self.capacity)
        var intermediate: Intermediate = initial
        for element in self {
            let output: Output
            (intermediate, output) = transformer(intermediate, element)
            transformedElements.append(output)
        }

        return (intermediate, transformedElements)
    }
}
