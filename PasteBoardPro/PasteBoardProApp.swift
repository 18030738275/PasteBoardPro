import SwiftUI
import Carbon.HIToolbox

class AppDelegate: NSObject, NSApplicationDelegate {
    var monitor = ClipboardMonitor()
    private var hotKeyRef: EventHotKeyRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        do {
            try DatabaseManager.shared.setup()
        } catch {
            print("Database setup error: \(error)")
        }
        monitor.start()
        registerHotkey()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
        }
    }

    private func registerHotkey() {
        // ⌘+Shift+V
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x50425052) // "PBPR"
        hotKeyID.id = 1

        InstallEventHandler(GetApplicationEventTarget(), { (_, event, _) -> OSStatus in
            var hkID = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hkID)
            if hkID.id == 1 {
                DispatchQueue.main.async {
                    AppDelegate.togglePopover()
                }
            }
            return noErr
        }, 1, [EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))], nil, nil)

        RegisterEventHotKey(0x09, UInt32(cmdKey | shiftKey), hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    static func togglePopover() {
        NSApp.activate(ignoringOtherApps: true)
        // 找到状态栏按钮并点击
        if let statusItem = NSApp.windows.first(where: { $0.className.contains("StatusBar") }) {
            statusItem.makeKeyAndOrderFront(nil)
        }
        // 备用：通过 NSStatusBar 找按钮
        for window in NSApp.windows {
            if let button = window.contentView?.subviews.first(where: { $0 is NSButton }) as? NSButton {
                button.performClick(nil)
                return
            }
        }
    }
}

@main
struct PasteBoardProApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    private var monitor: ClipboardMonitor {
        appDelegate.monitor
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView(monitor: monitor)
        } label: {
            Image(systemName: "clipboard.fill")
        }
        .menuBarExtraStyle(.window)
        .defaultSize(width: 360, height: 480)

        Window("PasteBoard Pro 设置", id: "settings") {
            SettingsView(monitor: monitor)
        }
        .defaultSize(width: 320, height: 300)
    }
}
