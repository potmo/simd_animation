import Foundation

struct QuadraticEasingFunction: EasingFunction {
    func map(_ gradient: Double) -> Double {
        return gradient * gradient
    }
}
