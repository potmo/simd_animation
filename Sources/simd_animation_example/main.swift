import Foundation
import simd
import simd_animation

let animator = Animator()

animator.enqueueSequence{
    LinearTranslation(duration: 3, from: [0,0,0], to: [1,0,0])
    LinearTranslation(duration: 3, to: [1,0,1])

    Delay(duration: 3)

    InParallel{
        LinearTranslation(duration: 10, from: [0,0,0], to: [1,1,1])
        LinearRotation(duration: 5,
                       from: { simd_quatf(angle: 90, axis: [0,0,1]) },
                       to: { simd_quatf(angle: 0, axis: [0,0,1]) })
    }

    InParallel {
        LinearRotation(duration: 5,
                       from: { simd_quatf(angle: 0, axis: [0,0,1]) },
                       to: { simd_quatf(angle: 90, axis: [0,0,1]) })
        InSequence{
            LinearTranslation(duration: 2.5, from: [0,0,0], to: [1,0,0])
            LinearTranslation(duration: 2.5, from: [1,0,0], to: [1,0,1])
        }
    }

    if true {
        LinearTranslation(duration: 10, from: [0,0,0], to: [1,0,0])
    }

    While{
        return true
    }

    Call{
        print("All done")
    }
}

var position = simd_float3()
var orientation = simd_quatf()

Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
    (position, orientation) = animator.tick(time: Date().timeIntervalSince1970, with: position, and: orientation)

    print("pos: \(position.x.fixed(2)),\(position.y.fixed(2)),\(position.z.fixed(2)) rot: \(orientation.vector.x.fixed(2)),\(orientation.vector.y.fixed(2)),\(orientation.vector.z.fixed(2)),\(orientation.vector.w.fixed(2))")
    }

RunLoop.main.run()
