import Foundation
import simd

public struct InSequence: AnimationRig {

    let rigs: [AnimationRig]
    public init(rigs: [AnimationRig]) {
        self.rigs = rigs
    }

    public init(@AnimationArrayBuilder builder: () -> [AnimationRig]) {
        self.rigs = builder()
    }

    public func create(at time: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner {
        return Runner(startPosition: position, startOrientation: orientation, rigs: rigs, at: time)
    }


    private class Runner: AnimationRunner {

        private var runner: AnimationRunner?
        private var pendingRigs: [AnimationRig]
        private var lastKnownPosition: simd_float3
        private var lastKnownOrientation: simd_quatf


        init(startPosition: simd_float3, startOrientation: simd_quatf, rigs: [AnimationRig], at time: Double) {
            self.lastKnownPosition = startPosition
            self.lastKnownOrientation = startOrientation
            self.pendingRigs = rigs
            self.runner = nil
        }

        func apply(at time: Double) -> AnimationResult {
            if self.runner == nil {
                if pendingRigs.isEmpty {
                    return .finishedNone(atTime: time)
                }
                let rig = self.pendingRigs.remove(at: pendingRigs.startIndex)
                self.runner = rig.create(at: time, with: lastKnownPosition, and: lastKnownOrientation)
            }

            guard let runner else {
                fatalError("trying to run a sequence with no runner")
            }

            let result = runner.apply(at: time)

            switch result {
                case .runningNone:
                    return result

                case .runningPosition(let position):
                    lastKnownPosition = position
                    return result

                case .runningOrientation(let orientation):
                    lastKnownOrientation = orientation
                    return result

                case .runningPositionOrientation(let position, let orientation):
                    lastKnownPosition = position
                    lastKnownOrientation = orientation
                    return result

                case .finishedNone(let finishTime):
                    return dequeueRunner(at: finishTime)

                case .finishedPosition(let position, let finishTime):
                    lastKnownPosition = position
                    return dequeueRunner(at: finishTime)

                case .finishedOrientation(let orientation, let finishTime):
                    lastKnownOrientation = orientation
                    return dequeueRunner(at: finishTime)

                case .finishedPositionOrientation(let position, let orientation, let finishTime):
                    lastKnownPosition = position
                    lastKnownOrientation = orientation
                    return dequeueRunner(at: finishTime)
            }
        }

        private func dequeueRunner(at time: Double) -> AnimationResult {
            if pendingRigs.isEmpty {
                return .finishedNone(atTime: time)
            }

            let nextRig = pendingRigs.remove(at: pendingRigs.startIndex)

            self.runner = nextRig.create(at: time, with: lastKnownPosition, and: lastKnownOrientation)

            // recurse until all elements are done for this time
            return self.apply(at: time)
        }
    }
}

