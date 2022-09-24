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
        return Runner(rigs: rigs, at: time)
    }


    private class Runner: AnimationRunner {

        private var runner: AnimationRunner?
        private var pendingRigs: [AnimationRig]

        init(rigs: [AnimationRig], at time: Double) {

            self.pendingRigs = rigs
            self.runner = nil
        }

        func apply(to position: simd_float3, and  orientation: simd_quatf, with time: Double) -> AnimationResult {

            if self.runner == nil {
                guard let rig = self.pendingRigs.popLast() else {
                    return .finished(position: position, orientaion: orientation, atTime: time)
                }

                self.runner = rig.create(at: time, with: position, and: orientation)
            }

            guard let runner else {
                fatalError("trying to run a sequence with no runner")
            }

            let result = runner.apply(to: position, and: orientation, with: time)

            switch result {
                case .running:
                    return result
                case .finished(let position, let orientaion, let finishTime):

                    guard !pendingRigs.isEmpty else {
                        return result
                    }

                    let nextRig = pendingRigs.remove(at: pendingRigs.startIndex)

                    self.runner = nextRig.create(at: finishTime, with: position, and: orientation)

                    // recurse until all elements are done for this time
                    return self.apply(to: position, and: orientaion, with: time)
            }

        }
    }

}

