import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateSpaceNumber()

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(spaceChanged),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )
    }

    @objc func spaceChanged() {
        updateSpaceNumber()
    }

    func updateSpaceNumber() {
        guard let info = CGSCopyManagedDisplaySpaces(CGSMainConnectionID()) as? [[String: Any]] else {
            statusItem.button?.title = "?"
            return
        }

        for display in info {
            guard let currentSpace = display["Current Space"] as? [String: Any],
                  let currentID = currentSpace["ManagedSpaceID"] as? Int,
                  let spaces = display["Spaces"] as? [[String: Any]] else { continue }

            for (index, space) in spaces.enumerated() {
                if let sid = space["ManagedSpaceID"] as? Int, sid == currentID {
                    statusItem.button?.title = "\(index + 1)"
                    return
                }
            }
        }
        statusItem.button?.title = "?"
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
