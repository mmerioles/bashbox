import Foundation

/// The Bashbox roadmap. Condensed from the W3Schools Bash tutorial
/// (https://www.w3schools.com/bash/) into the core concepts an everyday
/// engineer needs, ordered so each lesson builds on the last.
public enum Curriculum {
    public static let categories: [Category] = [
        gettingStarted,
        basics,
        textProcessing,
        systemMonitoring,
        networking,
        compression,
        permissions,
        scripting,
    ]

    public static var lessons: [Lesson] { categories.flatMap(\.lessons) }

    public static func lesson(_ id: String) -> Lesson? {
        lessons.first { $0.id == id }
    }

    public static func category(of lesson: Lesson) -> Category? {
        categories.first { $0.lessons.contains(lesson) }
    }

    public static func next(after lesson: Lesson) -> Lesson? {
        let all = lessons
        guard let i = all.firstIndex(of: lesson), i + 1 < all.count else { return nil }
        return all[i + 1]
    }

    public static func previous(before lesson: Lesson) -> Lesson? {
        let all = lessons
        guard let i = all.firstIndex(of: lesson), i > 0 else { return nil }
        return all[i - 1]
    }
}

// Short names keep the lesson files readable.
typealias N = Diagram.Node
typealias E = Diagram.Edge
typealias G = Diagram.Group
typealias S = LessonSection
typealias O = CommandOption
typealias F = Seed.File

// MARK: - Seed data shared by a few lessons

enum SeedData {
    /// A deterministic web-server log with INFO, WARN and ERROR lines.
    static let serverLog: String = {
        let events: [(String, String)] = [
            ("INFO", "server started on port 8080"),
            ("INFO", "GET /index.html 200 12ms"),
            ("INFO", "GET /api/users 200 48ms"),
            ("WARN", "slow query: SELECT * FROM orders (1204ms)"),
            ("INFO", "GET /api/orders 200 1290ms"),
            ("ERROR", "database connection timeout after 30s"),
            ("INFO", "retrying database connection"),
            ("INFO", "database connection restored"),
            ("INFO", "POST /api/login 200 31ms"),
            ("WARN", "disk usage at 85%"),
            ("INFO", "GET /static/app.js 304 2ms"),
            ("ERROR", "POST /api/payments 500 internal server error"),
            ("INFO", "GET /health 200 1ms"),
            ("WARN", "Timeout while calling inventory-service"),
            ("INFO", "GET /api/products 200 22ms"),
            ("INFO", "user 42 logged out"),
            ("ERROR", "failed to send email: SMTP Timeout"),
            ("INFO", "cache cleared"),
            ("INFO", "GET /api/users/42 200 9ms"),
            ("INFO", "server shutting down"),
        ]
        var lines: [String] = []
        for (i, event) in events.enumerated() {
            let minute = String(format: "%02d", 10 + i)
            lines.append("2026-10-17 09:\(minute):00 [\(event.0)] \(event.1)")
        }
        return lines.joined(separator: "\n") + "\n"
    }()

    static let serverLogLastLine = "2026-10-17 09:29:00 [INFO] server shutting down"
    static let serverLogFirstLine = "2026-10-17 09:10:00 [INFO] server started on port 8080"

    static func filler(_ label: String, kilobytes: Int) -> String {
        let line = "\(label) lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod\n"
        let count = max(1, kilobytes * 1024 / line.utf8.count)
        return String(repeating: line, count: count)
    }
}
