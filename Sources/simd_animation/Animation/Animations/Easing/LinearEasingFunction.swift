import Foundation

struct LinearEasingFunction: EasingFunction {
    func map(_ gradient: Double) -> Double {
        return gradient
    }
}
