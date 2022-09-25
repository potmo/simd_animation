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

        func apply(at time: Double, setPosition: (simd_float3) -> Void, setOrientation: (simd_quatf) -> Void) -> AnimationResult {
            let setLastKnownPositionAndReport = { position in
                self.lastKnownPosition = position
                setPosition(position)
            }

            let setLastKnownOrientationAndReport = { orientation in
                self.lastKnownOrientation = orientation
                setOrientation(orientation)
            }
            return self.applyInternal(at: time,
                                      setPosition: setLastKnownPositionAndReport,
                                      setOrientation: setLastKnownOrientationAndReport)
        }

        private func applyInternal(at time: Double, setPosition: (simd_float3) -> Void, setOrientation: (simd_quatf) -> Void) -> AnimationResult {
            if self.runner == nil {
                if pendingRigs.isEmpty {
                    return .finished(atTime: time)
                }
                let rig = self.pendingRigs.remove(at: pendingRigs.startIndex)
                self.runner = rig.create(at: time, with: lastKnownPosition, and: lastKnownOrientation)
            }

            guard let runner else {
                fatalError("trying to run a sequence with no runner")
            }

            let result = runner.apply(at: time, setPosition: setPosition, setOrientation: setOrientation)

            switch result {
                case .running:
                    return result

                case .finished(let finishTime):
                    return dequeueRunner(at: finishTime, setPosition: setPosition, setOrientation: setOrientation)
            }
        }

        private func dequeueRunner(at time: Double, setPosition: (simd_float3) -> Void, setOrientation: (simd_quatf) -> Void) -> AnimationResult {
            if pendingRigs.isEmpty {
                return .finished(atTime: time)
            }

            let nextRig = pendingRigs.remove(at: pendingRigs.startIndex)

            self.runner = nextRig.create(at: time, with: lastKnownPosition, and: lastKnownOrientation)

            // recurse until all elements are done for this time
            return self.applyInternal(at: time, setPosition: setPosition, setOrientation: setOrientation)
        }
    }
}

