import Foundation

struct CubicEasingFunction: EasingFunction {
    func map(_ gradient: Double) -> Double {
        return gradient * gradient * gradient
    }
}
