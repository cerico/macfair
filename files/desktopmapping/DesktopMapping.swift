import Cocoa
import ApplicationServices

struct DesktopEntry {
    let number: Int
    let app: String
    let sites: [String]
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var entries: [DesktopEntry] = []
    var accessibilityGranted = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        checkAccessibility()
        entries = loadConfig()
        updateTitle()
        buildMenu()

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(spaceChanged),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )
    }

    @objc func spaceChanged() {
        updateTitle()
        buildMenu()
    }

    func checkAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        accessibilityGranted = AXIsProcessTrustedWithOptions(options)
    }

    func updateTitle() {
        let num = currentSpaceIndex().map(String.init) ?? "?"
        statusItem.button?.title = num
    }

    let spaceKeyCodes: [Int: UInt16] = [
        1: 18, 2: 19, 3: 20, 4: 21, 5: 23, 6: 22, 7: 26, 8: 28,
        9: 25, 10: 29, 11: 12, 12: 13, 13: 14, 14: 15, 15: 17, 16: 16
    ]

    @objc func switchToDesktop(_ sender: NSMenuItem) {
        guard accessibilityGranted else {
            checkAccessibility()
            return
        }
        guard let keyCode = spaceKeyCodes[sender.tag] else { return }
        let src = CGEventSource(stateID: .hidSystemState)
        if let down = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true),
           let up = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false) {
            down.flags = .maskControl
            up.flags = .maskControl
            down.post(tap: .cghidEventTap)
            up.post(tap: .cghidEventTap)
        }
    }

    func currentSpaceIndex() -> Int? {
        guard let info = CGSCopyManagedDisplaySpaces(CGSMainConnectionID()) as? [[String: Any]] else {
            return nil
        }

        for display in info {
            guard let currentSpace = display["Current Space"] as? [String: Any],
                  let currentID = currentSpace["ManagedSpaceID"] as? Int,
                  let spaces = display["Spaces"] as? [[String: Any]] else { continue }

            for (index, space) in spaces.enumerated() {
                if let sid = space["ManagedSpaceID"] as? Int, sid == currentID {
                    return index + 1
                }
            }
        }
        return nil
    }

    @objc func openAccessibility() {
        checkAccessibility()
        if !accessibilityGranted,
           let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
        buildMenu()
    }

    func buildMenu() {
        let menu = NSMenu()
        let current = currentSpaceIndex()

        if !accessibilityGranted {
            let warning = NSMenuItem(title: "⚠ Accessibility permission required", action: #selector(openAccessibility), keyEquivalent: "")
            warning.target = self
            menu.addItem(warning)
            menu.addItem(NSMenuItem.separator())
        }

        for entry in entries {
            let prefix = entry.number == current ? "▶ " : "   "
            let title = "\(prefix)\(entry.number). \(entry.app)"
            let item = NSMenuItem(title: title, action: #selector(switchToDesktop(_:)), keyEquivalent: "")
            item.target = self
            item.tag = entry.number

            if entry.number == current {
                item.attributedTitle = NSAttributedString(
                    string: title,
                    attributes: [.font: NSFont.boldSystemFont(ofSize: 13)]
                )
            }

            if !entry.sites.isEmpty {
                let submenu = NSMenu()
                for site in entry.sites {
                    let siteItem = NSMenuItem(title: site, action: #selector(switchToDesktop(_:)), keyEquivalent: "")
                    siteItem.tag = entry.number
                    siteItem.target = self
                    submenu.addItem(siteItem)
                }
                item.submenu = submenu
            }

            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    func loadConfig() -> [DesktopEntry] {
        let path = NSString(string: "~/.config/desktops.yml").expandingTildeInPath
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return []
        }

        var results: [DesktopEntry] = []
        var currentNumber: Int?
        var currentApp: String?
        var currentSites: [String] = []
        var inSites = false

        for line in content.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if line.hasPrefix("  ") && !line.hasPrefix("    ") && trimmed.hasSuffix(":") {
                if let num = currentNumber, let app = currentApp {
                    results.append(DesktopEntry(number: num, app: app, sites: currentSites))
                }
                let key = trimmed.dropLast()
                currentNumber = Int(key)
                currentApp = nil
                currentSites = []
                inSites = false
            } else if trimmed.hasPrefix("app:") {
                currentApp = trimmed.dropFirst(4).trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            } else if trimmed == "sites:" {
                inSites = true
            } else if trimmed.hasPrefix("cask:") {
                // skip
            } else if inSites && trimmed.hasPrefix("- ") {
                currentSites.append(String(trimmed.dropFirst(2)))
            } else if !trimmed.isEmpty && !trimmed.hasPrefix("-") {
                inSites = false
            }
        }

        if let num = currentNumber, let app = currentApp {
            results.append(DesktopEntry(number: num, app: app, sites: currentSites))
        }

        return results.sorted { $0.number < $1.number }
    }
}

@_silgen_name("CGSCopyManagedDisplaySpaces")
func CGSCopyManagedDisplaySpaces(_ conn: Int32) -> CFArray?

@_silgen_name("CGSMainConnectionID")
func CGSMainConnectionID() -> Int32

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
