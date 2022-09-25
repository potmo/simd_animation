import Foundation
import Numerics

struct PowerEasingFunction: EasingFunction {

    private let power: Double
    init(power: Double) {
        self.power = power
    }

    func map(_ gradient: Double) -> Double {
        let y = max(0.0, power)
        return pow(gradient, y)
    }
}

