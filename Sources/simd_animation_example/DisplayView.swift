import Cocoa
import SwiftUI

class DisplayView: NSView {

    private var arrow: AnimatedArrow

    init() {
        self.arrow = AnimatedArrow()
        super.init(frame: NSRect(x: 0, y: 0, width: 1000, height: 1000))

    }

    override init(frame frameRect: NSRect) {
        fatalError("init(frame:) has not been implemented")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else {
            print("no context")
            return
        }

        // flip y-axis so origin is in top left corner
        let flipVerticalTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: self.frame.size.height)
        context.concatenate(flipVerticalTransform)
        context.setStrokeColor(CGColor.init(red: 1, green: 0, blue: 0, alpha: 1))
        context.setLineWidth(1.0)

        arrow.draw(context: context, time: Date().timeIntervalSince1970)

        DispatchQueue.main.async {
            self.setNeedsDisplay(self.bounds)
        }


    }

}
