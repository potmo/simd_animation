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
        let sequence = InSequence(rigs: [RunningAnimation(runner: currentAnimation), animation])
        currentAnimation = sequence.create(at: Date().timeIntervalSince1970, with: position, and: orientation)
    }

    public func enqueue(from position: simd_float3,
                                and orientation: simd_quatf,
                                @AnimationArrayBuilder _ builder: () -> [AnimationRig]) {
        let rigs = builder()
        self.enqueue(from: position, and: orientation, InSequence(rigs: rigs))
    }

    public func tick(time: Double,
                     updatePosition: (simd_float3) -> Void,
                     updateOrientation: (simd_quatf) -> Void ) -> Void {


        let state = currentAnimation.apply(at: time, setPosition: updatePosition, setOrientation: updateOrientation)

        switch state {
            case .finished(_):
                self.currentAnimation = Idle().create()
            case .running:
                break
        }

    }
}

public protocol AnimationRig {
    func create(at time: Double, with position: simd_float3, and orientation: simd_quatf) -> AnimationRunner
}


public protocol AnimationRunner {
    func apply(at time: Double, setPosition: (simd_float3) -> Void, setOrientation: (simd_quatf) -> Void) -> AnimationResult
}

public enum AnimationResult {

    case running
    case finished(atTime: Double)


    var isFinished: Bool {
        switch self {
            case .finished:
                return true
            case .running:
                return false
        }
    }

    var finishingTime: Double? {
        switch self {
            case .running:
                return nil

            case .finished(let time):
                return time
        }
    }
}

