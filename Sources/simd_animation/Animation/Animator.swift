import Foundation
import simd

public class Animator {

    //TODO: Check out these easing functions
    // https://github.com/danro/jquery-easing/blob/master/jquery.easing.js

    private var queue: [AnimationRig]
    private var currentAnimation: AnimationRunner

    public init() {
        self.queue = []
        self.currentAnimation = Idle().create(at: Date().timeIntervalSince1970, with: simd_float3(), and: simd_quatf())
    }

    public func enqueue(_ animation: AnimationRig) {
        queue.insert(animation, at: queue.startIndex)
    }

    public func enqueueSequence(@AnimationArrayBuilder _ builder: () -> [AnimationRig]) {
        let rigs = builder()
        queue.insert( InSequence(rigs: rigs), at: queue.startIndex)
    }

    public func enqueueInParallel(@AnimationArrayBuilder _ builder: () -> [AnimationRig]) {
        let rigs = builder()
        queue.insert( InParallel(rigs: rigs), at: queue.startIndex)
    }

    public func tick(time: Double, with position: simd_float3, and orientation: simd_quatf) -> (simd_float3, simd_quatf) {

        while true {
            let state = currentAnimation.apply(to: position, and: orientation, with: time)

            switch state {
                case .running(let newPosition, let newOrientation):
                    return (newPosition, newOrientation)
                case .finished(let newPosition, let newOrientation, let finishTime):
                    guard let newAnimation = queue.popLast() else {
                        self.currentAnimation = Idle().create(at: finishTime, with: newPosition, and: orientation)
                        return (newPosition, newOrientation)
                    }

                    self.currentAnimation = newAnimation.create(at: finishTime, with: newPosition, and: orientation)
            }
        }
    }
}

public protocol AnimationRig {
    func create(at time: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner
}


public protocol AnimationRunner {
    func apply(to position: simd_float3, and orientation: simd_quatf, with time: Double) -> AnimationResult
}

public enum AnimationResult {
    case running(position: simd_float3, orientaion: simd_quatf)
    case finished(position: simd_float3, orientaion: simd_quatf, atTime: Double)

    var isFinished: Bool {
        switch self {
            case .finished:
                return true
            case .running:
                return false
        }
    }

    var position: simd_float3 {
        switch self {
            case .finished(let position, _, _):
                return position
            case .running(let position, _):
                return position
        }
    }

    var orientation: simd_quatf {
        switch self {
            case .finished(_, let orientation, _):
                return orientation
            case .running(_, let orientation):
                return orientation
        }
    }
}

