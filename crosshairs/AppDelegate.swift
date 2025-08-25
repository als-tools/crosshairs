import Cocoa

enum CrosshairStyle {
    case solid
    case dashed
    case dotted
}

class CrosshairView: NSView {
    var crosshairColor: NSColor = .white
    var crosshairThickness: CGFloat = 2.0
    var crosshairStyle: CrosshairStyle = .solid
    var keepoutRadius: CGFloat = 20.0 // pixels

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        ctx.setStrokeColor(crosshairColor.cgColor)
        ctx.setLineWidth(crosshairThickness)

        // Set line style
        switch crosshairStyle {
        case .solid:
            ctx.setLineDash(phase: 0, lengths: [])
        case .dashed:
            ctx.setLineDash(phase: 0, lengths: [10, 6])
        case .dotted:
            ctx.setLineDash(phase: 0, lengths: [2, 6])
        }

        let w = bounds.width
        let h = bounds.height

        let mouseLoc = NSEvent.mouseLocation
        let x = mouseLoc.x
        let y = mouseLoc.y

        // Draw horizontal line (with keepout region)
        ctx.move(to: CGPoint(x: 0, y: y))
        ctx.addLine(to: CGPoint(x: x - keepoutRadius, y: y))
        ctx.move(to: CGPoint(x: x + keepoutRadius, y: y))
        ctx.addLine(to: CGPoint(x: w, y: y))

        // Draw vertical line (with keepout region)
        ctx.move(to: CGPoint(x: x, y: 0))
        ctx.addLine(to: CGPoint(x: x, y: y - keepoutRadius))
        ctx.move(to: CGPoint(x: x, y: y + keepoutRadius))
        ctx.addLine(to: CGPoint(x: x, y: h))

        ctx.strokePath()
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let screen = NSScreen.main!
        let frame = screen.frame

        window = NSWindow(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.hasShadow = false

        let view = CrosshairView(frame: frame)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor

        // Customize crosshair here:
        view.crosshairColor = .systemRed
        view.crosshairThickness = 1.0
        view.crosshairStyle = .dashed // .solid, .dashed, .dotted
        view.keepoutRadius = 10.0

        window.contentView = view
        window.makeKeyAndOrderFront(nil)

        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            view.setNeedsDisplay(view.bounds)
        }
    }
}
