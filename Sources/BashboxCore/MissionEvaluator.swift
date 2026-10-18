import Foundation

/// Decides whether a mission's check is satisfied, given the lesson workspace
/// on disk and the commands typed while the lesson was open.
public struct MissionEvaluator {
    public let workspace: URL
    public let commands: [CommandRecord]
    private let fm = FileManager.default

    public init(workspace: URL, commands: [CommandRecord]) {
        self.workspace = workspace
        self.commands = commands
    }

    public func isSatisfied(_ check: Check) -> Bool {
        switch check {
        case .ran(let pattern):
            return commands.contains { Self.matches($0.command, pattern) }
        case .ranOK(let pattern):
            return commands.contains { $0.status == 0 && Self.matches($0.command, pattern) }
        case .ranIn(let pattern, let suffix):
            return commands.contains {
                Self.matches($0.command, pattern) && ($0.directory + "/").hasSuffix("/" + suffix + "/")
            }
        case .exists(let path, let kind):
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: url(path).path, isDirectory: &isDir) else { return false }
            switch kind {
            case .any: return true
            case .file: return !isDir.boolValue
            case .directory: return isDir.boolValue
            }
        case .missing(let path):
            // Check the link itself too, so a dangling symlink still counts as present.
            return !fm.fileExists(atPath: url(path).path)
                && (try? fm.destinationOfSymbolicLink(atPath: url(path).path)) == nil
        case .contains(let path, let text):
            return read(path)?.contains(text) ?? false
        case .matches(let path, let pattern):
            guard let text = read(path) else { return false }
            return Self.matches(text, pattern)
        case .mode(let path, let mode):
            return permissions(path) == mode
        case .executable(let path):
            guard let p = permissions(path) else { return false }
            return p & 0o100 != 0
        case .group(let path, let group):
            let attrs = try? fm.attributesOfItem(atPath: url(path).path)
            return (attrs?[.groupOwnerAccountName] as? String) == group
        case .all(let checks):
            return checks.allSatisfy(isSatisfied)
        case .any(let checks):
            return checks.contains(where: isSatisfied)
        case .not(let inner):
            return !isSatisfied(inner)
        }
    }

    private func url(_ path: String) -> URL {
        workspace.appendingPathComponent(path)
    }

    private func read(_ path: String) -> String? {
        try? String(contentsOf: url(path), encoding: .utf8)
    }

    private func permissions(_ path: String) -> Int? {
        let attrs = try? fm.attributesOfItem(atPath: url(path).path)
        return (attrs?[.posixPermissions] as? NSNumber)?.intValue
    }

    static func matches(_ text: String, _ pattern: String) -> Bool {
        text.range(of: pattern, options: .regularExpression) != nil
    }
}
