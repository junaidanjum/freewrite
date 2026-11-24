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
