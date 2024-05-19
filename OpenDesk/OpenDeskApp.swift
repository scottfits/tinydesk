import SwiftUI
import AppKit

@main
struct MenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(named: "llama")
            button.action = #selector(togglePopover)
        }
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 500, height: 200)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView())
        
        statusItem?.button?.target = self
        statusItem?.button?.action = #selector(togglePopover)
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func captureScreen() -> NSImage? {
        guard let windowInfoList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] else {
            return nil
        }

        var windowsToExclude: [CGWindowID] = []

        for windowInfo in windowInfoList {
            if let ownerName = windowInfo[kCGWindowOwnerName as String] as? String, ownerName == "MenuBarApp" {
                if let windowID = windowInfo[kCGWindowNumber as String] as? CGWindowID {
                    windowsToExclude.append(windowID)
                }
            }
        }

        let options: CGWindowListOption = windowsToExclude.isEmpty ? [.optionOnScreenOnly] : [.optionOnScreenOnly, .excludeDesktopElements]

        let imageRef = CGWindowListCreateImage(CGRectNull, options, kCGNullWindowID, [.nominalResolution])

        guard let image = imageRef else {
            return nil
        }

        let bitmapRep = NSBitmapImageRep(cgImage: image)
        let nsImage = NSImage()
        nsImage.addRepresentation(bitmapRep)

        return nsImage
    }
}
