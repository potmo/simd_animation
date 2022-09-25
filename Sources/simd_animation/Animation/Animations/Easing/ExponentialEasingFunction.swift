import Foundation
import Numerics

struct ExponentialEasingFunction: EasingFunction {

    private let exponent: Double
    init(exponent: Double) {
        self.exponent = exponent
    }

    func map(_ gradient: Double) -> Double {
        if exponent <= 0 {
            return gradient
        }

        return (Double.exp(exponent * gradient) - 1.0) / (Double.exp(exponent) - 1.0)
    }
}

