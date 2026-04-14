import CoreGraphics

@_silgen_name("CGSCopyManagedDisplaySpaces")
func CGSCopyManagedDisplaySpaces(_ conn: Int32) -> CFArray?

@_silgen_name("CGSMainConnectionID")
func CGSMainConnectionID() -> Int32

guard let info = CGSCopyManagedDisplaySpaces(CGSMainConnectionID()) as? [[String: Any]] else { exit(1) }
for display in info {
    guard let currentSpace = display["Current Space"] as? [String: Any],
          let currentID = currentSpace["ManagedSpaceID"] as? Int,
          let spaces = display["Spaces"] as? [[String: Any]] else { continue }
    for (index, space) in spaces.enumerated() {
        if let sid = space["ManagedSpaceID"] as? Int, sid == currentID {
            print(index + 1)
            exit(0)
        }
    }
}
exit(1)
