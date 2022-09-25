import Foundation
import Numerics

struct ElasticEasingFunction: EasingFunction {

    private let oscillations: Double
    private let springiness: Double

    init(oscillations: Double, springiness: Double) {
        self.oscillations = oscillations
        self.springiness = springiness
    }

    func map(_ gradient: Double) -> Double {

        let num3 = max(0.0, oscillations)
        let num = max(0.0, springiness)

        let num2: Double
        if (num == 0) {
            num2 = gradient
        } else {
            num2 = (Double.exp(num * gradient) - 1.0) / (Double.exp(num) - 1.0)
        }
        return num2 * sin((6.2831853071795862 * num3 + 1.5707963267948966) * gradient)
    }
}

