import Foundation


import Foundation

struct CircleEasingFunction: EasingFunction {
    func map(_ gradient: Double) -> Double {
        return 1.0 - sqrt(1.0 - gradient * gradient)
    }
}
