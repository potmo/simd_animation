import Foundation
import simd
import simd_animation

class AnimatedArrow {

    private var position: simd_float3
    private var orientation: simd_quatf
    private let animator: Animator
    private var color: CGColor

    init() {
        self.position = [100,100,0]
        self.orientation = simd_quatf(angle: 0, axis: [0,0,1])
        self.animator = Animator()
        self.color = CGColor(red: 1, green: 0, blue: 0, alpha: 1)

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

        context.setStrokeColor(self.color)

        context.beginPath()
        context.move(to: position.cgPoint)
        context.addLine(to: (position + direction).cgPoint)
        context.addLine(to: (position + direction + leftWing).cgPoint)
        context.move(to: (position + direction).cgPoint)
        context.addLine(to: (position + direction + rightWing).cgPoint)
        context.strokePath()
        
    }

    func createAnimation(with animator: Animator) {

        animator.enqueue(from: position, and: orientation){

            Delay(duration: 1)

            LinearRotation(duration: 2, to: simd_quatf(angle: Float.pi/2, axis: [0,0,1]), using: .easeOut(.bounce()))

            Delay(duration: 1.0)

            Call{
                self.color = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
            }

            Delay(duration: 1.0)

            LinearTranslation(duration: 1, from: [100,100,0], to: [200,100,0], using: .easeOut(.elastic()))

            Delay(duration: 1.0)

            InParallel{
                LinearRotation(duration: 5, to: simd_quatf(angle: Float.pi, axis: [0,0,1]), using: .easeOut(.bounce()))
                
                InSequence{
                    Delay(duration: 0.5)
                    LinearTranslation(duration: 4, from: [200,100,0], to: [100,100,0], using: .easeOut(.bounce()))
                }

            }
            Delay(duration: 0.5)
            
            LinearTranslation(duration: 3, from: [100,100,0], to: [200,100,0], using: .easeInOut(.sine))
            Delay(duration: 0.5)

            LinearTranslation(duration: 3, from: [100,100,0], to: [200,100,0], using: .easeInOut(.quadratic))
            Delay(duration: 0.5)

            LinearTranslation(duration: 3, from: [100,100,0], to: [200,100,0], using: .easeInOut(.power(power: 2)))
            Delay(duration: 0.5)

            LinearTranslation(duration: 3, from: [100,100,0], to: [200,100,0], using: .easeInOut(.elastic(oscillations: 3, springiness: 3)))
            Delay(duration: 0.5)

            LinearTranslation(duration: 3, from: [100,100,0], to: [200,100,0], using: .easeInOut(.cubic))
            Delay(duration: 0.5)

            LinearTranslation(duration: 3, from: [100,100,0], to: [200,100,0], using: .easeInOut(.bounce(bounces: 3, bounciness: 2)))
            Delay(duration: 0.5)

            LinearTranslation(duration: 3, from: [100,100,0], to: [200,100,0], using: .easeInOut(.exponential(exponent: 2)))
            Delay(duration: 0.5)

            LinearTranslation(duration: 3, from: [100,100,0], to: [200,100,0], using: .easeInOut(.circle))
            Delay(duration: 0.5)

            LinearTranslation(duration: 3, from: [100,100,0], to: [200,100,0], using: .easeInOut(.back(amplitude: 1)))
            Delay(duration: 0.5)

            LinearRelativeToCurrentPositionTranslation(duration: 1, to: [200, 100, 0])
            LinearRotation(duration: 1, to: simd_quatf(angle: Float.pi , axis: [0,0,1]))

            InParallel{
                LinearRelativeToCurrentPositionTranslation(duration: 1, to: [100, 200, 0])
                LinearRotation(duration: 1, to: simd_quatf(angle: Float.pi/2 , axis: [0,0,1]))
            }


            

        }
    }
}

fileprivate extension simd_float3 {
    var cgPoint: CGPoint {
        return CGPoint(x: Double(self.x), y: Double(self.y))
    }
}
