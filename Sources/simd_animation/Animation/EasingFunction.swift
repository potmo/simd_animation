import Foundation

public enum EasingType {
    case linear
    case exponential(exponent: Double = 2)
    case circle
    case back(amplitude: Double = 1)
    case bounce(bounces: Double = 3, bounciness: Double = 2)
    case cubic
    case elastic(oscillations: Double = 3, springiness: Double = 3)
    case power(power: Double = 2)
    case quadratic
    case sine

    var function: EasingFunction {
        switch self {
            case .linear:
                return LinearEasingFunction()

            case .exponential(let exponent):
                return ExponentialEasingFunction(exponent: exponent)

            case .circle:
                return CircleEasingFunction()

            case .back(let amplitude):
                return BackEasingFunction(amplitude: amplitude)

            case .bounce(let bounces, let bounciness):
                return BounceEasingFunction(bounces: bounces, bounciness: bounciness)

            case .cubic:
                return CubicEasingFunction()

            case .elastic(let oscillations, let springiness):
                return ElasticEasingFunction(oscillations: oscillations, springiness: springiness)

            case .power(let power):
                return PowerEasingFunction(power: power)

            case .quadratic:
                return QuadraticEasingFunction()

            case .sine:
                return SineEasingFunction()
        }
    }
}

struct Easer {
    let mode: EasingMode

    init(mode: EasingMode) {
        self.mode = mode
    }

    func map(_ gradient: Double) -> Double {

        if gradient <= 0 {
            return 0
        }

        if gradient >= 1.0 {
            return 1.0
        }

        switch mode {
            case .easeIn(let type):
                return type.function.map(gradient)
            case .easeOut(let type):
                return 1 - type.function.map(1 - gradient)
            case .easeInOut(let type):
                if gradient >= 0.5 {
                    return (1 - type.function.map((1 - gradient) * 2)) * 0.5 + 0.5
                } else {
                    return type.function.map(gradient * 2) * 0.5
                }
        }
    }
}

public enum EasingMode {
    case easeIn(_ using: EasingType)
    case easeOut(_ using: EasingType)
    case easeInOut(_ using: EasingType)
}

protocol EasingFunction {
    func map(_ gradient: Double) -> Double
}
