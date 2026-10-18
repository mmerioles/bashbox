import XCTest
@testable import BashboxCore

final class CurriculumTests: XCTestCase {
    func testIdsAreUnique() {
        let ids = Curriculum.lessons.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "duplicate lesson ids")
        let cats = Curriculum.categories.map(\.id)
        XCTAssertEqual(cats.count, Set(cats).count, "duplicate category ids")
    }

    func testEveryLessonHasContent() {
        for lesson in Curriculum.lessons {
            XCTAssertFalse(lesson.sections.isEmpty, lesson.id)
            XCTAssertFalse(lesson.missions.isEmpty, lesson.id)
            XCTAssertFalse(lesson.reference.isEmpty, lesson.id)
        }
    }

    func testDiagramsAreWellFormed() {
        for lesson in Curriculum.lessons {
            let d = lesson.diagram
            let ids = Set(d.nodes.map(\.id))
            XCTAssertEqual(ids.count, d.nodes.count, "\(lesson.id): duplicate node ids")
            let cells = d.nodes.map { "\($0.col),\($0.row)" }
            XCTAssertEqual(cells.count, Set(cells).count, "\(lesson.id): two nodes share a grid cell")
            for edge in d.edges {
                XCTAssertTrue(ids.contains(edge.from), "\(lesson.id): unknown edge source \(edge.from)")
                XCTAssertTrue(ids.contains(edge.to), "\(lesson.id): unknown edge target \(edge.to)")
            }
            for group in d.groups {
                for member in group.members {
                    XCTAssertTrue(ids.contains(member), "\(lesson.id): unknown group member \(member)")
                }
            }
        }
    }

    func testAllRegexesCompile() {
        func patterns(_ check: Check) -> [String] {
            switch check {
            case .ran(let p), .ranOK(let p), .ranIn(let p, _), .matches(_, let p): return [p]
            case .all(let c), .any(let c): return c.flatMap(patterns)
            case .not(let c): return patterns(c)
            default: return []
            }
        }
        for lesson in Curriculum.lessons {
            for mission in lesson.missions {
                for p in patterns(mission.check) {
                    XCTAssertNoThrow(try NSRegularExpression(pattern: p), "\(lesson.id): bad regex \(p)")
                }
            }
        }
    }
}

final class WorkspaceTests: XCTestCase {
    var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("bashbox-tests-\(UUID().uuidString)")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: root)
    }

    func testCommandRecordParsing() {
        let r = CommandRecord(logLine: "1\t/tmp/x\tgrep -c\tWARN file")
        XCTAssertEqual(r?.status, 1)
        XCTAssertEqual(r?.directory, "/tmp/x")
        XCTAssertEqual(r?.command, "grep -c\tWARN file")
        XCTAssertNil(CommandRecord(logLine: "garbage"))
    }

    /// No mission should already be complete in a freshly seeded workspace.
    func testFreshWorkspaceCompletesNothing() throws {
        let ws = Workspace(root: root)
        try ws.prepare()
        for lesson in Curriculum.lessons {
            let dir = try ws.ensure(lesson)
            let eval = MissionEvaluator(workspace: dir, commands: [])
            for mission in lesson.missions {
                XCTAssertFalse(eval.isSatisfied(mission.check), "\(lesson.id): '\(mission.title)' is done before starting")
            }
        }
    }

    func testResetRestoresSeed() throws {
        let ws = Workspace(root: root)
        try ws.prepare()
        let lesson = Curriculum.lesson("managing-files")!
        let dir = try ws.ensure(lesson)
        try FileManager.default.removeItem(at: dir.appendingPathComponent("report-draft.txt"))
        try ws.reset(lesson)
        XCTAssertTrue(FileManager.default.fileExists(atPath: dir.appendingPathComponent("report-draft.txt").path))
    }

    /// Runs the generated profile in a real interactive bash and checks that
    /// commands get logged, with their exit status, and space-prefixed ones don't.
    func testProfileLogsCommands() throws {
        let ws = Workspace(root: root)
        try ws.prepare()
        let lesson = Curriculum.lesson("navigation")!
        let dir = try ws.ensure(lesson)

        let input = "echo hi\n cd /tmp\nfalse\n\nls -la\nexit\n"
        _ = try runBash(args: ws.shellArguments, env: ws.environment(startIn: dir), stdin: input, cwd: dir)

        let records = ws.readNewCommands()
        XCTAssertEqual(records.map(\.command), ["echo hi", "false", "ls -la"])
        XCTAssertEqual(records.map(\.status), [0, 1, 0])
        XCTAssertTrue(records[0].directory.hasSuffix("/navigation"))
        XCTAssertTrue(ws.readNewCommands().isEmpty, "log lines are consumed once")
    }

    /// Runs every mission's model solution through bash and checks that the
    /// mission then counts as complete. Catches checks that are too strict,
    /// and solutions that don't work on macOS.
    func testSolutionsCompleteEveryMission() throws {
        let ws = Workspace(root: root)
        try ws.prepare()
        let network = ProcessInfo.processInfo.environment["BASHBOX_OFFLINE"] == nil

        for lesson in Curriculum.lessons {
            if lesson.id == "web" && !network { continue }
            let dir = try ws.ensure(lesson)

            // Each solution is split into commands. Heredoc solutions stay whole.
            var commands: [String] = []
            for mission in lesson.missions {
                if mission.solution.contains("<<") {
                    commands.append(mission.solution)
                } else {
                    commands += mission.solution.split(separator: "\n").map(String.init)
                }
            }

            // One bash session per lesson so variables, functions and jobs carry
            // over between commands, as they would in the app.
            var script = "shopt -s expand_aliases\ncd \"\(dir.path)\"\n"
            let out = root.appendingPathComponent("\(lesson.id).records")
            for (i, cmd) in commands.enumerated() {
                let file = root.appendingPathComponent("\(lesson.id).\(i).cmd")
                try cmd.write(to: file, atomically: true, encoding: .utf8)
                script += "eval \"$(cat '\(file.path)')\" </dev/null >/dev/null 2>&1; s=$?; printf '%s\\t%s\\t%s\\n' \"$s\" \"$PWD\" \"\(i)\" >> '\(out.path)'\n"
            }
            var env = ws.environment(startIn: dir)
            env += ["PAGER=cat", "MANPAGER=cat"]
            _ = try runBash(args: ["-c", script], env: env, stdin: "", cwd: dir)

            let lines = (try? String(contentsOf: out, encoding: .utf8)) ?? ""
            let records: [CommandRecord] = lines.split(separator: "\n").compactMap {
                let parts = $0.split(separator: "\t")
                guard parts.count == 3, let s = Int32(parts[0]), let i = Int(parts[2]) else { return nil }
                return CommandRecord(status: s, directory: String(parts[1]), command: commands[i])
            }
            let eval = MissionEvaluator(workspace: dir, commands: records)
            for mission in lesson.missions {
                XCTAssertTrue(eval.isSatisfied(mission.check), "\(lesson.id): solution for '\(mission.title)' doesn't satisfy its check\n\(records)")
            }
        }
    }

    @discardableResult
    private func runBash(args: [String], env: [String], stdin: String, cwd: URL) throws -> String {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/bin/bash")
        p.arguments = args
        p.currentDirectoryURL = cwd
        var dict: [String: String] = [:]
        for kv in env {
            let parts = kv.split(separator: "=", maxSplits: 1)
            if parts.count == 2 { dict[String(parts[0])] = String(parts[1]) }
        }
        p.environment = dict
        let inPipe = Pipe(), outPipe = Pipe()
        p.standardInput = inPipe
        p.standardOutput = outPipe
        p.standardError = outPipe
        try p.run()
        inPipe.fileHandleForWriting.write(stdin.data(using: .utf8)!)
        try inPipe.fileHandleForWriting.close()
        let data = outPipe.fileHandleForReading.readDataToEndOfFile()
        p.waitUntilExit()
        return String(decoding: data, as: UTF8.self)
    }
}
