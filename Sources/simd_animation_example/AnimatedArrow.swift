import Foundation
import simd
import simd_animation

class AnimatedArrow {

    private var position: simd_float3
    private var orientation: simd_quatf
    private let animator: Animator

    init() {
        self.position = [100,100,0]
        self.orientation = simd_quatf(angle: 0, axis: [0,0,1])
        self.animator = Animator()
        self.createAnimation(with: animator)

    }

    func draw(context: CGContext, time: Double) {

        animator.tick(time: time,
                      updatePosition: { self.position = $0},
                      updateOrientation: {self.orientation = $0})

        let backLeft = orientation * simd_quatf(angle: Float.pi - Float.pi/6, axis: [0,0,1])
        let backRight = orientation * simd_quatf(angle: Float.pi + Float.pi/6, axis: [0,0,1])


        let direction = orientation.act([20,0,0])
        let leftWing = backLeft.act([10,0,0])
        let rightWing = backRight.act([10,0,0])

        context.setStrokeColor(red: 255, green: 0, blue: 0, alpha: 1)

        context.beginPath()
        context.move(to: position.cgPoint)
        context.addLine(to: (position + direction).cgPoint)
        context.addLine(to: (position + direction + leftWing).cgPoint)
        context.move(to: (position + direction).cgPoint)
        context.addLine(to: (position + direction + rightWing).cgPoint)
        context.strokePath()
        
    }

    func createAnimation(with animator: Animator) {

        animator.enqueueSequence(from: position, and: orientation){

            LinearTranslation(duration: 2, to: [200, 100, 0])
            LinearRotation(duration: 2, to: simd_quatf(angle: Float.pi , axis: [0,0,1]))

            InParallel{
                LinearTranslation(duration: 2, to: [100, 200, 0])
                LinearRotation(duration: 2, to: simd_quatf(angle: Float.pi/2 , axis: [0,0,1]))
            }

            LinearRotation(duration: 2, to: simd_quatf(angle: Float.pi * 2 , axis: [0,0,1]))

        }
    }
}

fileprivate extension simd_float3 {
    var cgPoint: CGPoint {
        return CGPoint(x: Double(self.x), y: Double(self.y))
    }
}
