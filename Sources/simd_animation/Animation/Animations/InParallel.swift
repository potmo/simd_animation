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

        func apply(to position: simd_float3, and  orientation: simd_quatf, with time: Double) -> AnimationResult {


            let ((endPosition, endOrientation), results) = runners.sweep((position, orientation)) { positionOrientation, runner in
                let result = runner.apply(to: positionOrientation.0, and: positionOrientation.1, with: time)

                let newPosition: simd_float3
                let newOrientation: simd_quatf
                switch result {
                    case .running(let position, let orientation):
                        newPosition = position
                        newOrientation = orientation
                    case .finished(let position, let orientation, _):
                        newPosition = position
                        newOrientation = orientation
                }
                return ((newPosition, newOrientation), result)
            }

            var lastFinishTime: Double = 0
            for result in results {
                switch result {
                    case .running(_, _):
                        return .running(position: endPosition, orientaion: endOrientation)
                    case .finished(_, _, let finishTime):
                        lastFinishTime = max(lastFinishTime, finishTime)
                }
            }

            return .finished(position: endPosition, orientaion: endOrientation, atTime: lastFinishTime)

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
