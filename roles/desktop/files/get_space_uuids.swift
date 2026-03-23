import Cocoa

@_silgen_name("CGSCopyManagedDisplaySpaces")
func CGSCopyManagedDisplaySpaces(_ conn: Int32) -> CFArray?

@_silgen_name("CGSMainConnectionID")
func CGSMainConnectionID() -> Int32

guard let info = CGSCopyManagedDisplaySpaces(CGSMainConnectionID()) as? [[String: Any]] else {
    fputs("{}\n", stderr)
    exit(1)
}

var result: [String: String] = [:]

for display in info {
    guard display["Display Identifier"] as? String == "Main",
          let spaces = display["Spaces"] as? [[String: Any]] else { continue }
    for (i, space) in spaces.enumerated() {
        if let uuid = space["uuid"] as? String, !uuid.isEmpty {
            result[String(i + 1)] = uuid
        }
    }
}

if let data = try? JSONSerialization.data(withJSONObject: result),
   let json = String(data: data, encoding: .utf8) {
    print(json)
} else {
    fputs("{}\n", stderr)
    exit(1)
}
