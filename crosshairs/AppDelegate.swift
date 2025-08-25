import Cocoa

class CrosshairView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.setStrokeColor(NSColor.white.cgColor)
        ctx.setLineWidth(2.0)

        let w = bounds.width
        let h = bounds.height

        // Get mouse location in screen coordinates
        let mouseLoc = NSEvent.mouseLocation
        let screenFrame = NSScreen.main?.frame ?? NSRect.zero
        let x = mouseLoc.x
        let y = mouseLoc.y // flip Y

        // Draw horizontal line
        ctx.move(to: CGPoint(x: 0, y: y))
        ctx.addLine(to: CGPoint(x: w, y: y))
        // Draw vertical line
        ctx.move(to: CGPoint(x: x, y: 0))
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
        window.contentView = view
        window.makeKeyAndOrderFront(nil)

        // Timer to redraw crosshair as mouse moves
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            view.setNeedsDisplay(view.bounds)
        }
    }
}
