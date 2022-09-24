import Foundation
import simd

public class Animator {

    //TODO: Check out these easing functions
    // https://github.com/danro/jquery-easing/blob/master/jquery.easing.js

    private var currentAnimation: AnimationRunner

    public init() {
        self.currentAnimation = Idle().create()
    }

    public func enqueue(from position: simd_float3, and orientation: simd_quatf, _ animation: AnimationRig) {
        // if there are already something queued we need to put that into the sequence
        currentAnimation = InSequence(rigs: [animation]).create(at: 0, with: position, and: orientation)
    }

    public func enqueueSequence(from position: simd_float3,
                                and orientation: simd_quatf,
                                @AnimationArrayBuilder _ builder: () -> [AnimationRig]) {
        let rigs = builder()
        self.enqueue(from: position, and: orientation, InSequence(rigs: rigs))
    }

    public func tick(time: Double,
                     updatePosition: (simd_float3) -> Void,
                     updateOrientation: (simd_quatf) -> Void ) -> Void {


        let state = currentAnimation.apply(at: time)

        switch state {
            case .runningPositionOrientation(let position, let orientation):
                updatePosition(position)
                updateOrientation(orientation)
            case .finishedPositionOrientation(let position, let orientation, _):
                updatePosition(position)
                updateOrientation(orientation)
                self.currentAnimation = Idle().create()
            case .runningPosition(let position):
                updatePosition(position)
            case .finishedPosition(let position, _):
                updatePosition(position)
                self.currentAnimation = Idle().create()
            case .runningOrientation(let orientation):
                updateOrientation(orientation)
            case .finishedOrientation(let orientation, _):
                updateOrientation(orientation)
                self.currentAnimation = Idle().create()
            case .finishedNone(_):
                self.currentAnimation = Idle().create()
            case .runningNone:
                break
        }

    }
}

public protocol AnimationRig {
    func create(at time: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner
}


public protocol AnimationRunner {
    func apply(at time: Double) -> AnimationResult
}

public enum AnimationResult {
    case runningPositionOrientation(position: simd_float3, orientation: simd_quatf)
    case finishedPositionOrientation(position: simd_float3, orientation: simd_quatf, atTime: Double)

    case runningPosition(position: simd_float3)
    case finishedPosition(position: simd_float3, atTime: Double)

    case runningOrientation(orientation: simd_quatf)
    case finishedOrientation(orientation: simd_quatf, atTime: Double)

    case runningNone
    case finishedNone(atTime: Double)


    var isFinished: Bool {
        switch self {
            case .runningPositionOrientation:
                return false
            case .finishedPositionOrientation:
                return true
            case .runningPosition:
                return false
            case .finishedPosition:
                return true
            case .runningOrientation:
                return false
            case .finishedOrientation:
                return true
            case .finishedNone:
                return true
            case .runningNone:
                return false
        }
    }

    var finishingTime: Double? {
        switch self {
            case .runningPositionOrientation, .runningPosition, .runningOrientation, .runningNone:
                return nil
            case .finishedPositionOrientation(_, _, let time):
                return time
            case .finishedPosition(_, let time):
                return time
            case .finishedOrientation(_, let time):
                return time
            case .finishedNone(let time):
                return time
        }
    }

    var position: simd_float3? {
        switch self {
            case .runningPositionOrientation:
                return nil
            case .finishedPositionOrientation(let position, _, _):
                return position
            case .runningPosition(let position):
                return position
            case .finishedPosition(let position, _):
                return position
            case .runningOrientation:
                return nil
            case .finishedOrientation:
                return nil
            case .runningNone:
                return nil
            case .finishedNone:
                return nil
        }
    }

    var orientation: simd_quatf? {
        switch self {
            case .runningPositionOrientation(_, let orientation):
                return orientation
            case .finishedPositionOrientation(_, let orientation, _):
                return orientation
            case .runningPosition:
                return nil
            case .finishedPosition:
                return nil
            case .runningOrientation(let orientation):
                return orientation
            case .finishedOrientation(let orientation, _):
                return orientation
            case .runningNone:
                return nil
            case .finishedNone:
                return nil
        }
    }
}

