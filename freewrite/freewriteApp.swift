//
//  freewriteApp.swift
//  freewrite
//
//  Created by thorfinn on 2/14/25.
//

import SwiftUI

@main
struct freewriteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("colorScheme") private var colorSchemeString: String = "light"

    init() {
        // Register Lato font
        if let fontURL = Bundle.main.url(forResource: "Lato-Regular", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorSchemeString == "dark" ? .dark : .light)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1100, height: 600)
        .windowToolbarStyle(.unifiedCompact)
        .windowResizability(.contentSize)
        .commands {
            ZoomCommands()
        }
    }
}

struct ZoomScaleKey: FocusedValueKey {
    typealias Value = Binding<CGFloat>
}

extension FocusedValues {
    var zoomScale: Binding<CGFloat>? {
        get { self[ZoomScaleKey.self] }
        set { self[ZoomScaleKey.self] = newValue }
    }
}

enum Zoom {
    // Matches Apple Notes: 4 steps down to 50%, 8 steps up to 300%
    static let levels: [CGFloat] = [0.5, 0.625, 0.75, 0.875, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3]
    static let actualSize: CGFloat = 1

    static func larger(than scale: CGFloat) -> CGFloat? {
        levels.first { $0 > scale }
    }

    static func smaller(than scale: CGFloat) -> CGFloat? {
        levels.last { $0 < scale }
    }
}

struct ZoomCommands: Commands {
    @FocusedBinding(\.zoomScale) private var zoomScale

    var body: some Commands {
        CommandGroup(before: .toolbar) {
            Button("Zoom In") {
                if let zoomScale, let larger = Zoom.larger(than: zoomScale) {
                    self.zoomScale = larger
                }
            }
            .keyboardShortcut("+", modifiers: .command)
            .disabled(zoomScale.flatMap(Zoom.larger) == nil)

            Button("Zoom Out") {
                if let zoomScale, let smaller = Zoom.smaller(than: zoomScale) {
                    self.zoomScale = smaller
                }
            }
            .keyboardShortcut("-", modifiers: .command)
            .disabled(zoomScale.flatMap(Zoom.smaller) == nil)

            Button("Actual Size") {
                zoomScale = Zoom.actualSize
            }
            .keyboardShortcut("0", modifiers: .command)
            .disabled(zoomScale.map { $0 == Zoom.actualSize } ?? true)

            Divider()
        }
    }
}

// Add AppDelegate to handle window configuration
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            // Ensure window starts in windowed mode
            if window.styleMask.contains(.fullScreen) {
                window.toggleFullScreen(nil)
            }

            // Center the window on the screen
            window.center()

            WindowButtonHoverView.install(in: window)
        }

        NotificationCenter.default.addObserver(forName: NSWindow.didBecomeKeyNotification, object: nil, queue: .main) { notification in
            if let window = notification.object as? NSWindow {
                WindowButtonHoverView.install(in: window)
            }
        }
    }
}

// A tracking area reports enter and exit even when the window is inactive, so the buttons don't flicker.
final class WindowButtonHoverView: NSView {
    private static let zoneSize = NSSize(width: 100, height: 40)
    private static let fadeDuration: TimeInterval = 0.2
    private static let buttonTypes: [NSWindow.ButtonType] = [.closeButton, .miniaturizeButton, .zoomButton]

    static func install(in window: NSWindow) {
        guard window.standardWindowButton(.closeButton) != nil,
              let contentView = window.contentView,
              !contentView.subviews.contains(where: { $0 is WindowButtonHoverView }) else {
            return
        }

        let originY = contentView.isFlipped ? 0 : contentView.bounds.height - zoneSize.height
        let hoverView = WindowButtonHoverView(frame: NSRect(origin: NSPoint(x: 0, y: originY), size: zoneSize))
        hoverView.autoresizingMask = contentView.isFlipped ? [.maxXMargin, .maxYMargin] : [.maxXMargin, .minYMargin]
        contentView.addSubview(hoverView)
        hoverView.setButtons(visible: false, animated: false)
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach(removeTrackingArea)
        addTrackingArea(NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self))
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }

    override func mouseEntered(with event: NSEvent) {
        setButtons(visible: true, animated: true)
    }

    override func mouseExited(with event: NSEvent) {
        setButtons(visible: false, animated: true)
    }

    private func setButtons(visible: Bool, animated: Bool) {
        guard let window else { return }
        // In fullscreen macOS reveals the buttons itself from the top edge
        let targetAlpha: CGFloat = visible || window.styleMask.contains(.fullScreen) ? 1 : 0
        let buttons = Self.buttonTypes.compactMap { window.standardWindowButton($0) }

        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = Self.fadeDuration
                buttons.forEach { $0.animator().alphaValue = targetAlpha }
            }
        } else {
            buttons.forEach { $0.alphaValue = targetAlpha }
        }
    }
}
