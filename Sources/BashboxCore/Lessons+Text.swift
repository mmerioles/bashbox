import Foundation

extension Curriculum {
    static let textProcessing = Category(
        id: "text-processing", title: "Text Processing", icon: "text.alignleft",
        blurb: "Chain small tools with pipes to search, slice, sort and rewrite text.",
        lessons: [pipes, grepLesson, slicing, sedAwk]
    )

    static let pipes = Lesson(
        id: "pipes",
        title: "Pipes, redirection, head & tail",
        commands: ["|", ">", "2>", "head", "tail", "wc"],
        topics: ["stdin, stdout, stderr", "Output redirection", "Input redirection", "Error redirection", "Pipes", "head", "tail", "wc"],
        summary: "Every program has an input and two outputs. Redirection points them at files, and pipes connect one program's output to the next one's input.",
        sections: [
            S("Three streams", """
            Every process starts with three streams: **stdin** (0) for input, **stdout** (1) for normal output, and **stderr** (2) for errors. By default all three are connected to your terminal.
            """),
            S("Redirection", """
            `>` sends stdout to a file and `>>` appends to it. `2>` sends stderr somewhere else, so errors can go to their own file. `2>&1` merges stderr into stdout, and `< file` feeds a file to stdin.
            """, example: Example("ls real.txt missing.txt > found.txt 2> errors.txt")),
            S("Pipes", """
            The pipe `|` connects one command's stdout to the next command's stdin. This is the core idea of the shell: small tools that each do one thing, chained together.
            """, example: Example("grep ERROR server.log | wc -l", output: "3")),
            S("head, tail and wc", """
            `head -n 5 file` shows the first 5 lines, and `tail -n 5 file` shows the last 5. `tail -f file` keeps the file open and prints new lines as they arrive, which is perfect for watching logs (Ctrl+C to stop).

            `wc -l` counts lines, `wc -w` counts words, and `wc -c` counts bytes.
            """, example: Example("tail -n 3 server.log")),
        ],
        reference: [
            O("CMD > FILE", "Write stdout to FILE (overwrite)"),
            O("CMD >> FILE", "Append stdout to FILE"),
            O("CMD 2> FILE", "Write stderr to FILE"),
            O("CMD > FILE 2>&1", "Write stdout and stderr to FILE"),
            O("CMD < FILE", "Use FILE as stdin"),
            O("A | B", "Pipe A's stdout into B's stdin"),
            O("head -n N FILE", "First N lines"),
            O("tail -n N FILE", "Last N lines"),
            O("tail -f FILE", "Follow a growing file"),
            O("wc -l FILE", "Count lines"),
            O("CMD > /dev/null", "Throw output away"),
        ],
        diagram: Diagram(
            "A pipeline: count the errors in a log",
            caption: "`cat server.log | grep ERROR | wc -l`. Each | joins one process's stdout to the next one's stdin, and the processes run at the same time. Errors (stderr) skip the pipe unless you redirect them.",
            nodes: [
                N("file", "server.log", icon: "doc.text", .file, at: 0, 0),
                N("cat", "cat", icon: "gearshape", .process, at: 1, 0, detail: "reads the file"),
                N("grep", "grep ERROR", icon: "line.3.horizontal.decrease", .process, at: 2, 0, detail: "keeps matches"),
                N("wc", "wc -l", icon: "number", .process, at: 3, 0, detail: "counts lines"),
                N("screen", "Terminal", icon: "display", .process, at: 4, 0, detail: "3"),
                N("stderr", "stderr (2)", icon: "exclamationmark.triangle", .stream, at: 2, 1, detail: "errors"),
                N("errfile", "errors.txt", icon: "doc.text", .file, at: 3, 1, detail: "2> errors.txt"),
            ],
            edges: [
                E("file", "cat", "stdin"),
                E("cat", "grep", "|"),
                E("grep", "wc", "|"),
                E("wc", "screen", "stdout"),
                E("grep", "stderr", nil, dashed: true),
                E("stderr", "errfile", "2>", dashed: true),
            ]
        ),
        seed: Seed(files: [
            F("server.log", SeedData.serverLog),
            F("real.txt", "I exist.\n"),
        ]),
        missions: [
            Mission("Show the first 5 lines of server.log", hint: "head with -n.", solution: "head -n 5 server.log", check: .ranOK(#"head\b.*(-n\s*5|-5)\b"#)),
            Mission("Show the last 3 lines of server.log", hint: "The opposite of head.", solution: "tail -n 3 server.log", check: .ranOK(#"tail\b.*(-n\s*3|-3)\b"#)),
            Mission("Count the ERROR lines using a pipe", hint: "grep finds the lines and wc counts them. Join them with |.", solution: "grep ERROR server.log | wc -l", check: .ranOK(#"grep.*ERROR.*\|\s*wc\s+-l"#)),
            Mission("Save the last 10 lines of server.log into recent.log", hint: "tail, then redirect with >.", solution: "tail -n 10 server.log > recent.log", check: .all([.contains("recent.log", SeedData.serverLogLastLine), .not(.contains("recent.log", SeedData.serverLogFirstLine))])),
            Mission("Send an error message into errors.txt", hint: "List a file that doesn't exist and redirect stream 2.", solution: "ls missing.txt 2> errors.txt", check: .contains("errors.txt", "No such file")),
        ]
    )

    static let grepLesson = Lesson(
        id: "grep",
        title: "Searching with grep & find",
        commands: ["grep", "find"],
        topics: ["grep", "Regular expressions", "find"],
        summary: "grep finds lines inside files, and find finds the files themselves. Together they answer \"where is that?\" in any project.",
        sections: [
            S("The basics", """
            `grep PATTERN FILE` prints every line of FILE that contains PATTERN. Leave out the file and grep reads stdin, so it works at the end of a pipe: `ps aux | grep python`.
            """, example: Example("grep ERROR server.log", output: "2026-10-17 09:15:00 [ERROR] database connection timeout after 30s\n…")),
            S("Options you'll use daily", """
            `-i` ignores case, `-n` prints line numbers, `-v` inverts the match (lines that _don't_ contain the pattern), `-c` counts matching lines, and `-r` searches every file in a folder. `-l` prints only the names of files that match.
            """, example: Example("grep -rn TODO src/", output: "src/app.js:3:// TODO: handle errors")),
            S("Patterns", """
            Patterns are **regular expressions**. `^` anchors to the start of a line and `$` to the end. `.` matches any character and `*` repeats the thing before it. With `-E` you also get `|` (or), `+` and `?`.

            Quote your pattern so bash doesn't interpret special characters first: `grep -E 'WARN|ERROR' server.log`.
            """),
            S("find: search for files", """
            grep looks _inside_ files. `find` searches by name, type, size or age. `find . -name "*.js"` lists every .js file under the current folder, `-type d` limits results to directories, and `-mtime -1` keeps files changed in the last day.

            Add `-exec` to act on each result: `find . -name "*.tmp" -exec rm {} +`. Run it without -exec first to see what it matches.
            """, example: Example("find . -name \"*.js\"", output: "./src/app.js\n./src/util.js")),
        ],
        reference: [
            O("grep PAT FILE", "Lines in FILE containing PAT"),
            O("grep -i", "Ignore case"),
            O("grep -n", "Show line numbers"),
            O("grep -v", "Invert: lines NOT matching"),
            O("grep -c", "Count matching lines"),
            O("grep -r PAT DIR", "Search recursively"),
            O("grep -l", "Only print file names"),
            O("grep -E 'A|B'", "Extended regex (A or B)"),
            O("grep -w", "Match whole words only"),
            O("^ / $", "Start / end of line"),
            O("find . -name \"*.js\"", "Files by name, recursively"),
            O("find . -type d", "Only directories"),
            O("find . -mtime -1", "Changed in the last day"),
            O("find … -exec CMD {} +", "Run CMD on the results"),
        ],
        diagram: Diagram(
            "grep is a filter",
            caption: "Every line goes in and only the matching lines come out. With -v, the two outputs swap places.",
            nodes: [
                N("file", "server.log", icon: "doc.text", .file, at: 0, 0, detail: "20 lines"),
                N("grep", "grep ERROR", icon: "line.3.horizontal.decrease", .process, at: 1, 0, detail: "test each line"),
                N("match", "Matching lines", icon: "checkmark.circle", .stream, at: 2, 0, detail: "3 lines"),
                N("screen", "Terminal / pipe", icon: "display", .process, at: 3, 0),
                N("drop", "Other lines", icon: "xmark.circle", .system, at: 2, 1, detail: "discarded"),
            ],
            edges: [
                E("file", "grep", "every line"),
                E("grep", "match", "matches"),
                E("match", "screen", "stdout"),
                E("grep", "drop", "no match (-v keeps these)", dashed: true),
            ]
        ),
        seed: Seed(
            directories: ["src"],
            files: [
                F("server.log", SeedData.serverLog),
                F("src/app.js", "import { load } from './util.js'\n\n// TODO: handle errors\nconst data = load('users')\nconsole.log(data)\n"),
                F("src/util.js", "export function load(name) {\n  // TODO: read from disk\n  return []\n}\n"),
                F("src/styles.css", "body { margin: 0 }\n"),
            ]
        ),
        missions: [
            Mission("Print every ERROR line in server.log", hint: "grep PATTERN FILE.", solution: "grep ERROR server.log", check: .ranOK(#"grep\s+.*ERROR.*server\.log"#)),
            Mission("Count the WARN lines without using wc", hint: "grep has an option that counts.", solution: "grep -c WARN server.log", check: .ranOK(#"grep\b.*\s-[a-zA-Z]*c[a-zA-Z]*\s.*WARN|grep\b.*WARN.*\s-[a-zA-Z]*c\b"#)),
            Mission("Find \"timeout\" in any capitalization", hint: "Some lines say Timeout and some say timeout. One option ignores case.", solution: "grep -i timeout server.log", check: .ranOK(#"grep\b.*\s-[a-zA-Z]*i[a-zA-Z]*\s.*timeout|grep\b.*timeout.*\s-[a-zA-Z]*i\b"#)),
            Mission("Save every TODO in src/ with line numbers to todos.txt", hint: "Search recursively with line numbers, then redirect.", solution: "grep -rn TODO src > todos.txt", check: .matches("todos.txt", #"src/.*:\d+:.*TODO"#)),
            Mission("Show the lines that are NOT INFO", hint: "Invert the match.", solution: "grep -v INFO server.log", check: .ranOK(#"grep\b.*-[a-zA-Z]*v.*INFO"#)),
            Mission("Use find to list every .js file in this folder and below", hint: "find . -name with a quoted pattern.", solution: "find . -name \"*.js\"", check: .ranOK(#"find\s+\S+.*-i?name\s+\S*js"#)),
        ]
    )

    static let slicing = Lesson(
        id: "slicing",
        title: "Slicing data: cut, sort, uniq",
        commands: ["cut", "sort", "uniq", "wc"],
        topics: ["cut", "sort", "uniq", "wc", "tail -n +2"],
        summary: "Pull columns out of CSVs and logs, sort them, and count duplicates. These are the building blocks of quick, throwaway data analysis.",
        sections: [
            S("cut: pick columns", """
            `cut -d, -f2 file.csv` splits each line on commas (`-d,` sets the delimiter) and keeps field 2. Ask for several fields with `-f1,3` or a range with `-f2-4`.

            Need to skip a header row? `tail -n +2 file.csv` prints everything from line 2 onward.
            """, example: Example("cut -d, -f1 employees.csv | head -n 3", output: "name\nAda\nLinus")),
            S("sort", """
            `sort` sorts lines alphabetically. `-n` sorts numerically, `-r` reverses the order, and `-u` removes duplicates. To sort a CSV by a column, set the separator with `-t,` and the column with `-k3`.
            """, example: Example("sort -t, -k3 -nr employees.csv")),
            S("uniq and the classic pipeline", """
            `uniq` collapses repeated lines that sit next to each other, so always **sort first**. `uniq -c` puts a count in front of each line.

            This pipeline answers "what shows up most?" for almost any data: **cut → sort → uniq -c → sort -rn**.
            """, example: Example("cut -d' ' -f1 access.log | sort | uniq -c | sort -rn", output: "   5 10.0.0.7\n   3 10.0.0.2\n   2 10.0.0.9")),
        ],
        reference: [
            O("cut -d, -f2", "Field 2 of comma-separated lines"),
            O("cut -c1-10", "Characters 1 to 10 of each line"),
            O("sort", "Sort alphabetically"),
            O("sort -n / -r", "Numeric / reverse order"),
            O("sort -t, -k3", "Sort by column 3, comma-separated"),
            O("sort -u", "Sort and drop duplicates"),
            O("uniq", "Collapse adjacent duplicate lines"),
            O("uniq -c", "Prefix lines with their count"),
            O("tail -n +2", "Everything from line 2 (skip a header)"),
            O("wc -l", "Count lines"),
        ],
        diagram: Diagram(
            "Which IP sent the most requests?",
            caption: "Each stage reshapes the stream for the next one. uniq only sees adjacent lines, so the first sort groups duplicates together, and the last sort ranks them by count.",
            nodes: [
                N("log", "access.log", icon: "doc.text", .file, at: 0, 0, detail: "10.0.0.7 GET /…"),
                N("cut", "cut -d' ' -f1", icon: "scissors", .process, at: 1, 0, detail: "keep the IP"),
                N("sort1", "sort", icon: "arrow.up.arrow.down", .process, at: 2, 0, detail: "group repeats"),
                N("uniq", "uniq -c", icon: "number", .process, at: 3, 0, detail: "count runs"),
                N("sort2", "sort -rn", icon: "chart.bar", .process, at: 4, 0, detail: "biggest first"),
                N("out", "5 10.0.0.7", icon: "display", .stream, at: 4, 1, detail: "the answer"),
            ],
            edges: [
                E("log", "cut", "lines"),
                E("cut", "sort1", "|"),
                E("sort1", "uniq", "|"),
                E("uniq", "sort2", "|"),
                E("sort2", "out", "stdout"),
            ]
        ),
        seed: Seed(files: [
            F("employees.csv", """
            name,dept,salary,city
            Ada,Engineering,145000,London
            Linus,Engineering,138000,Portland
            Grace,Engineering,152000,Arlington
            Don,Marketing,98000,Austin
            Peggy,Marketing,105000,New York
            Joan,Design,112000,Seattle
            Dieter,Design,119000,Berlin
            Ken,Sales,91000,Chicago
            Ruth,Sales,99000,Denver
            Margaret,Engineering,161000,Boston

            """),
            F("access.log", """
            10.0.0.7 GET /index.html
            10.0.0.2 GET /about
            10.0.0.7 GET /pricing
            10.0.0.9 POST /login
            10.0.0.7 GET /dashboard
            10.0.0.2 GET /dashboard
            10.0.0.7 GET /settings
            10.0.0.9 GET /logout
            10.0.0.2 GET /index.html
            10.0.0.7 POST /api/save

            """),
        ]),
        missions: [
            Mission("Print just the names (column 1) from employees.csv", hint: "cut with a comma delimiter and field 1.", solution: "cut -d, -f1 employees.csv", check: .ranOK(#"cut\b.*-f\s*1\b"#)),
            Mission("Sort employees by salary, highest first", hint: "Separator is a comma, salary is column 3, numeric and reversed.", solution: "sort -t, -k3 -nr employees.csv", check: .ranOK(#"sort\b.*-k\s*3"#)),
            Mission("Save each department exactly once to departments.txt", hint: "cut column 2, then sort -u (or sort | uniq), then redirect.", solution: "tail -n +2 employees.csv | cut -d, -f2 | sort -u > departments.txt", check: .all([
                .matches("departments.txt", "(?m)^Engineering$"),
                .matches("departments.txt", "(?m)^Marketing$"),
                .matches("departments.txt", "(?m)^Design$"),
                .matches("departments.txt", "(?m)^Sales$"),
                .not(.matches("departments.txt", "(?ms)^Engineering$.*^Engineering$")),
            ])),
            Mission("Count how many requests each IP made in access.log", hint: "cut the first space-separated field, sort, then uniq -c.", solution: "cut -d' ' -f1 access.log | sort | uniq -c | sort -rn", check: .ranOK(#"uniq\s+-c"#)),
        ]
    )

    static let sedAwk = Lesson(
        id: "sed-awk",
        title: "Editing streams: sed & awk",
        commands: ["sed", "awk"],
        summary: "sed finds and replaces text line by line. awk splits each line into fields so you can print, filter and add them up.",
        sections: [
            S("sed: find and replace", """
            `sed 's/old/new/' file` replaces the first `old` on each line and prints the result. Add `g` to replace every match on the line: `s/old/new/g`. **The file itself doesn't change** unless you edit in place.

            Other everyday uses: `sed -n '3,5p'` prints only lines 3 to 5, and `sed '/DEBUG/d'` deletes the lines that match.
            """, example: Example("sed 's/staging/production/g' config.ini")),
            S("Editing in place", """
            `-i` writes the change back to the file. On macOS, `-i` needs an argument for the backup suffix, so pass an empty one: `sed -i '' 's/a/b/g' file`. On Linux it's just `sed -i 's/a/b/g' file`.
            """, example: Example("sed -i '' 's/staging/production/g' config.ini")),
            S("awk: think in columns", """
            awk splits each line into fields: `$1`, `$2`, and so on up to `$NF` (the last one). `awk '{print $2}'` prints the second column. `-F,` changes the separator.

            Put a condition before the braces to filter: `awk '$3 > 10'` prints rows whose third column is over 10. An `END` block runs after the last line, which is how you add things up.
            """, example: Example("awk '{sum += $3} END {print sum}' sales.txt", output: "113")),
        ],
        reference: [
            O("sed 's/A/B/'", "Replace first A with B on each line"),
            O("sed 's/A/B/g'", "Replace every A with B"),
            O("sed -i '' 's/A/B/g' F", "Edit F in place (macOS)"),
            O("sed -n '3,5p'", "Print only lines 3 to 5"),
            O("sed '/PAT/d'", "Delete lines matching PAT"),
            O("awk '{print $1}'", "Print the first field"),
            O("awk -F, '{print $2}'", "Comma-separated fields"),
            O("awk '$3 > 10'", "Rows where field 3 > 10"),
            O("awk '{s+=$3} END {print s}'", "Sum field 3"),
            O("$NF / NR", "Last field / current line number"),
        ],
        macNote: "macOS uses BSD sed and awk. The biggest difference is in-place editing: write `sed -i '' …` on macOS where Linux takes plain `sed -i …`.",
        diagram: Diagram(
            "Two line-by-line machines",
            caption: "sed reads each line into its pattern space, runs your script on it, and prints the result. awk splits each line into fields first, so your program can treat text like a table.",
            nodes: [
                N("cfg", "config.ini", icon: "doc.text", .file, at: 0, 0),
                N("sed", "sed", icon: "pencil.line", .process, at: 1, 0, detail: "pattern space"),
                N("script", "s/staging/production/g", icon: "curlybraces", .shell, at: 2, 0, detail: "per line"),
                N("out1", "stdout or -i file", icon: "arrow.right.doc.on.clipboard", .stream, at: 3, 0),
                N("sales", "sales.txt", icon: "doc.text", .file, at: 0, 1),
                N("awk", "awk", icon: "tablecells", .process, at: 1, 1, detail: "split into $1 $2 $3"),
                N("prog", "{sum += $3}", icon: "sum", .shell, at: 2, 1, detail: "END {print sum}"),
                N("out2", "113", icon: "display", .stream, at: 3, 1),
            ],
            groups: [G("sed: edit each line", ["sed", "script"]), G("awk: fields per line", ["awk", "prog"])],
            edges: [
                E("cfg", "sed", "line"),
                E("sed", "script"),
                E("script", "out1", "print"),
                E("sales", "awk", "line"),
                E("awk", "prog"),
                E("prog", "out2", "END"),
            ]
        ),
        seed: Seed(files: [
            F("config.ini", "env=staging\nhost=staging.example.com\nport=443\ndebug=true\n"),
            F("sales.txt", """
            north widget 12 4.50
            south widget 30 4.50
            east gadget 8 19.99
            west gadget 15 19.99
            north gizmo 22 7.25
            south gizmo 26 7.25

            """),
        ]),
        missions: [
            Mission("Preview config.ini with every \"staging\" replaced by \"production\"", hint: "sed 's/old/new/g' FILE prints without changing the file.", solution: "sed 's/staging/production/g' config.ini", check: .ranOK(#"sed\s+.*s/staging/production/g"#)),
            Mission("Now change config.ini itself", hint: "Edit in place. On macOS that's -i ''.", solution: "sed -i '' 's/staging/production/g' config.ini", check: .all([.contains("config.ini", "production"), .not(.contains("config.ini", "staging"))])),
            Mission("Print only the product column (2nd) of sales.txt", hint: "awk '{print $N}'.", solution: "awk '{print $2}' sales.txt", check: .ranOK(#"awk\b.*print\s+\$2"#)),
            Mission("Total the units (3rd column) and save the number to total.txt", hint: "Add $3 to a running sum, then print it in an END block.", solution: "awk '{sum += $3} END {print sum}' sales.txt > total.txt", check: .matches("total.txt", #"^\s*113\s*$"#)),
        ]
    )
}
