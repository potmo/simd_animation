import Foundation

struct SineEasingFunction: EasingFunction {
    func map(_ gradient: Double) -> Double {
        return 1.0 - sin(1.5707963267948966 * (1.0 - gradient))
    }
}
