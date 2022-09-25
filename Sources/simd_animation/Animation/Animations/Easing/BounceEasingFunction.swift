import Foundation
import Numerics

struct BounceEasingFunction: EasingFunction {

    private let bounces: Double
    private let bounciness: Double

    init(bounces: Double, bounciness: Double) {
        self.bounces = bounces
        self.bounciness = bounciness
    }

    func map(_ gradient: Double) -> Double {
        let y = max(0.0, bounces);
        let bounciness = max(bounciness, 0.001)

        let num9 = pow(bounciness, y)
        let num5 = 1.0 - bounciness
        let num4 = (1.0 - num9) / num5 + num9 * 0.5
        let num15 = gradient * num4
        let num65 = log(-num15 * (1.0 - bounciness) + 1.0) / log(bounciness)
        let num3 = num65.rounded(.down)
        let num13 = num3 + 1.0
        let num8 = (1.0 - pow(bounciness, num3)) / (num5 * num4)
        let num12 = (1.0 - pow(bounciness, num13)) / (num5 * num4)
        let num7 = (num8 + num12) * 0.5
        let num6 = gradient - num7
        let num2 = num7 - num8
        return (-pow(1.0 / bounciness, y - num3) / (num2 * num2)) * (num6 - num2) * (num6 + num2)
    }
}

