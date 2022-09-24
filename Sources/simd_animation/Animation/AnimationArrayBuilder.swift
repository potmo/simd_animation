import Foundation


@resultBuilder
public struct AnimationArrayBuilder {
    public typealias Component = [AnimationRig]
    public typealias Expression = AnimationRig
    public typealias Result = [AnimationRig]

    public static func buildExpression(_ element: Expression) -> Component {
        return [element]
    }
    public static func buildExpression() -> Component {
        return []
    }
    public static func buildOptional(_ component: Component?) -> Component {
        guard let component = component else { return [] }
        return component
    }
    public static func buildEither(first component: Component) -> Component {
        return component
    }
    public static func buildEither(second component: Component) -> Component {
        return component
    }
    public static func buildArray(_ components: [Component]) -> Component {
        return Array(components.joined())
    }
    public static func buildBlock(_ components: Component...) -> Component {
        return Array(components.joined())
    }
    public func buildFinalResult(_ component: Component) -> Result {
        return component
    }
}
