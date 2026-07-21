// Prints the CGWindowID of the largest on-screen window owned by the given app name.
// Used so `screencapture -l <id>` captures ONLY that app's window.
import CoreGraphics
import Foundation

let owner = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Giant Text"

guard let list = CGWindowListCopyWindowInfo(
    [.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID
) as? [[String: Any]] else {
    FileHandle.standardError.write("could not read window list\n".data(using: .utf8)!)
    exit(2)
}

var best: (id: CGWindowID, area: CGFloat)? = nil
for w in list {
    guard let name = w[kCGWindowOwnerName as String] as? String, name == owner,
          let id = w[kCGWindowNumber as String] as? CGWindowID,
          let b = w[kCGWindowBounds as String] as? [String: CGFloat],
          let width = b["Width"], let height = b["Height"] else { continue }
    let area = width * height
    if area < 10_000 { continue }            // skip tiny helper windows
    if best == nil || area > best!.area { best = (id, area) }
}

if let best {
    print(best.id)
} else {
    FileHandle.standardError.write("no window found for \(owner)\n".data(using: .utf8)!)
    exit(1)
}
