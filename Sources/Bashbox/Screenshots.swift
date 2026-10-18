import AppKit
import SwiftUI
import BashboxCore

/// `Bashbox --screenshots DIR` renders the app in a few demo states to PNGs
/// (used by the website in docs/) and quits. It runs against a throwaway
/// workspace with made-up progress, and the window is kept invisible.
enum Screenshots {
    static let outputDir: URL? = {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "--screenshots"), i + 1 < args.count else { return nil }
        return URL(fileURLWithPath: args[i + 1])
    }()

    static var isActive: Bool { outputDir != nil }

    static let workspaceRoot = FileManager.default.temporaryDirectory
        .appendingPathComponent("bashbox-screenshots-\(ProcessInfo.processInfo.processIdentifier)", isDirectory: true)
    static let defaultsSuite = "io.github.mmerioles.bashbox.screenshots"
    static let windowSize = CGSize(width: 1440, height: 900)

    /// Progress for the demo: the first two categories done, a few missions into the rest.
    @MainActor
    static var demoCompleted: Set<String> {
        var keys: Set<String> = []
        for category in Curriculum.categories.prefix(2) {
            for lesson in category.lessons {
                for i in lesson.missions.indices { keys.insert(AppModel.key(lesson, i)) }
            }
        }
        for (id, count) in [("pipes", 2), ("grep", 5), ("processes", 1), ("web", 3)] {
            guard let lesson = Curriculum.lesson(id) else { continue }
            for i in 0..<min(count, lesson.missions.count) { keys.insert(AppModel.key(lesson, i)) }
        }
        return keys
    }

    private struct Shot {
        let name: String
        let screen: Screen
        var collapsed = false
        var commands: [String] = []
    }

    private static let shots: [Shot] = [
        Shot(name: "lesson", screen: .lesson("pipes"), commands: [
            "head -n 5 server.log",
            "tail -n 3 server.log",
            "grep ERROR server.log | wc -l",
        ]),
        Shot(name: "focus", screen: .lesson("processes"), collapsed: true, commands: [
            "sleep 300 &",
            "sleep 600 &",
            "jobs -l",
            "kill %1",
        ]),
        Shot(name: "dashboard", screen: .dashboard),
        Shot(name: "roadmap", screen: .roadmap),
    ]

    @MainActor
    static func run(_ model: AppModel) async {
        guard let dir = outputDir else { return }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try? await Task.sleep(for: .milliseconds(300))
        guard let window = NSApp.windows.first(where: { $0.contentView != nil && $0.isVisible }) else {
            print("error: no window to capture")
            exit(1)
        }
        // Park the window behind every other app's windows so the run doesn't get in the way.
        window.setContentSize(windowSize)
        window.orderBack(nil)

        for shot in shots {
            model.sidebarCollapsed = shot.collapsed
            switch shot.screen {
            case .lesson(let id): if let lesson = Curriculum.lesson(id) { model.open(lesson) }
            case .dashboard: model.openDashboard()
            case .roadmap: model.openRoadmap()
            }
            try? await Task.sleep(for: .milliseconds(900))
            for command in shot.commands {
                model.terminal.view.send(txt: command + "\r")
                try? await Task.sleep(for: .milliseconds(450))
            }
            try? await Task.sleep(for: .milliseconds(900))
            save(window, to: dir.appendingPathComponent("\(shot.name).png"))
        }
        try? FileManager.default.removeItem(at: workspaceRoot)
        UserDefaults.standard.removePersistentDomain(forName: defaultsSuite)
        exit(0)
    }

    @MainActor
    private static func save(_ window: NSWindow, to url: URL) {
        // Ask the window server for this window's pixels. It works while the
        // window sits behind everything else, and includes the title bar.
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        p.arguments = ["-x", "-o", "-l", String(window.windowNumber), url.path]
        do {
            try p.run()
            p.waitUntilExit()
            print(p.terminationStatus == 0 ? "wrote \(url.path)" : "error: screencapture failed for \(url.lastPathComponent)")
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
}
