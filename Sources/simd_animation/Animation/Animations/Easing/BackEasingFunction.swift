import Foundation
import Numerics

struct BackEasingFunction: EasingFunction {

    private let amplitude: Double
    init(amplitude: Double) {
        self.amplitude = amplitude
    }

    func map(_ gradient: Double) -> Double {
        let num = max(0, amplitude);
        return pow(gradient, 3.0) - gradient * num * sin(Double.pi * gradient)
    }
}

