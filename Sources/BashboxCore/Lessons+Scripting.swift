import Foundation

extension Curriculum {
    // MARK: - File Permissions

    static let permissions = Category(
        id: "permissions", title: "File Permissions", icon: "lock",
        blurb: "Read permission strings, make scripts executable, and control who owns what.",
        lessons: [chmodLesson, ownership]
    )

    static let chmodLesson = Lesson(
        id: "chmod",
        title: "Reading & changing permissions",
        commands: ["ls -l", "chmod"],
        topics: ["ls -l", "rwx", "chmod", "Octal modes"],
        summary: "Every file says what its owner, its group, and everyone else may do with it. Learn to read that string and change it with chmod.",
        sections: [
            S("Reading -rwxr-xr--", """
            `ls -l` starts each line with ten characters. The first is the type: `-` for a file, `d` for a directory, `l` for a link. The remaining nine are three groups of three, for the **owner (u)**, the **group (g)** and **others (o)**.

            In each group, `r` means read, `w` means write, `x` means execute, and `-` means not allowed. On a directory, `x` means you can `cd` into it.
            """, example: Example("ls -l deploy.sh", output: "-rw-r--r--  1 you  staff  52 Oct 17 09:00 deploy.sh")),
            S("Symbolic chmod", """
            `chmod u+x file` adds execute for the owner. `chmod go-w file` removes write from group and others, and `chmod a+r file` lets everyone read. Combine changes with commas: `chmod u+x,o-r file`.
            """, example: Example("chmod +x deploy.sh && ./deploy.sh")),
            S("Numeric chmod", """
            Each permission has a number: **r = 4, w = 2, x = 1**. Add them up for each of user, group and other. `chmod 755` (rwxr-xr-x) is typical for scripts and folders, `644` (rw-r--r--) for regular files, and `600` (rw-------) for secrets only you should read.
            """, example: Example("chmod 600 secrets.env")),
        ],
        reference: [
            O("ls -l", "Show permissions, owner, group"),
            O("chmod +x FILE", "Make executable"),
            O("chmod u+x,go-w F", "Symbolic: add/remove per class"),
            O("chmod 755 F", "rwxr-xr-x (scripts, folders)"),
            O("chmod 644 F", "rw-r--r-- (regular files)"),
            O("chmod 600 F", "rw------- (private files)"),
            O("chmod -R MODE DIR", "Apply recursively"),
            O("r=4  w=2  x=1", "Add per class: 7=rwx, 5=r-x, 4=r--"),
        ],
        diagram: Diagram(
            "Decoding -rwxr-x---",
            caption: "Nine permission bits, three for each class of user. Add r=4, w=2 and x=1 in each class to get the digit chmod expects.",
            nodes: [
                N("file", "deploy.sh", icon: "doc.badge.gearshape", .file, at: 0, 1, detail: "-rwxr-x---"),
                N("owner", "Owner (u)", icon: "person.fill", .actor, at: 1, 0, detail: "rwx = 4+2+1 = 7"),
                N("group", "Group (g)", icon: "person.2.fill", .actor, at: 1, 1, detail: "r-x = 4+0+1 = 5"),
                N("other", "Others (o)", icon: "person.3", .actor, at: 1, 2, detail: "--- = 0"),
                N("mode", "chmod 750", icon: "number.square", .shell, at: 2, 1, detail: "same as u=rwx,g=rx,o="),
            ],
            edges: [
                E("file", "owner"),
                E("file", "group"),
                E("file", "other"),
                E("owner", "mode", "7"),
                E("group", "mode", "5"),
                E("other", "mode", "0"),
            ]
        ),
        seed: Seed(files: [
            F("deploy.sh", "#!/bin/bash\necho \"Deploying… done!\"\n", mode: 0o644),
            F("secrets.env", "API_KEY=sk-test-123\n", mode: 0o644),
            F("public/index.html", "<h1>Public</h1>\n", mode: 0o600),
        ]),
        missions: [
            Mission("Look at the permissions of every file here", hint: "ls with the long format.", solution: "ls -l", check: .ranOK(#"^\s*ls\s+(.*\s)?-[a-zA-Z]*l"#)),
            Mission("Make deploy.sh executable, then run it", hint: "chmod +x, then ./deploy.sh.", solution: "chmod +x deploy.sh\n./deploy.sh", check: .all([.executable("deploy.sh"), .ranOK(#"\./deploy\.sh"#)])),
            Mission("Make secrets.env readable and writable by you only", hint: "rw for owner and nothing for anyone else: 6, 0, 0.", solution: "chmod 600 secrets.env", check: .mode("secrets.env", 0o600)),
            Mission("Let everyone read public/index.html (644)", hint: "rw for owner, r for group and others.", solution: "chmod 644 public/index.html", check: .mode("public/index.html", 0o644)),
        ]
    )

    static let ownership = Lesson(
        id: "ownership",
        title: "Ownership: users & groups",
        commands: ["id", "chown", "chgrp"],
        topics: ["whoami", "id", "groups", "chown", "chgrp", "sudo"],
        summary: "Every file belongs to one user and one group. Permissions are checked against those, so changing ownership changes who gets access.",
        sections: [
            S("Who am I?", """
            `whoami` prints your username. `id` prints your user ID and every group you belong to, and `groups` prints just the group names. On macOS your files usually belong to the group `staff`.
            """, example: Example("id", output: "uid=501(you) gid=20(staff) groups=20(staff),12(everyone),80(admin)…")),
            S("chgrp", """
            `chgrp group file` changes a file's group. You can only pick a group you're a member of. `-R` changes a whole folder.
            """, example: Example("chgrp everyone shared.txt")),
            S("chown", """
            `chown user file` changes the owner, and `chown user:group file` changes both at once. Giving a file to **another** user takes admin rights: `sudo chown …`. Take `sudo` seriously, because it runs a command as root, where nothing is protected.
            """, example: Example("sudo chown -R www:www /var/www")),
        ],
        reference: [
            O("whoami", "Your username"),
            O("id", "Your user ID and groups"),
            O("groups", "Group names you belong to"),
            O("ls -l", "Show owner and group of files"),
            O("chgrp GROUP FILE", "Change the group"),
            O("chown USER FILE", "Change the owner (sudo for others)"),
            O("chown USER:GROUP F", "Change both"),
            O("chown -R / chgrp -R", "Apply to a whole folder"),
        ],
        diagram: Diagram(
            "Users, groups and a file",
            caption: "When you open a file, the system checks: are you its owner? Then the owner bits apply. Are you in its group? Then the group bits apply. Otherwise the 'others' bits apply.",
            nodes: [
                N("you", "you (uid 501)", icon: "person.fill", .actor, at: 0, 1),
                N("staff", "staff", icon: "person.2", .system, at: 1, 0, detail: "gid 20"),
                N("everyone", "everyone", icon: "person.3", .system, at: 1, 2, detail: "gid 12"),
                N("file", "shared.txt", icon: "doc.text", .file, at: 2, 1, detail: "you:staff  rw-r-----"),
                N("check", "Access check", icon: "checkmark.shield", .shell, at: 3, 1, detail: "owner? group? other?"),
            ],
            edges: [
                E("you", "staff", "member of"),
                E("you", "everyone", "member of"),
                E("you", "file", "owner"),
                E("staff", "file", "group", dashed: true),
                E("file", "check", "open()"),
            ]
        ),
        seed: Seed(files: [
            F("shared.txt", "notes everyone can see\n"),
            F("team/a.txt", "a\n"),
            F("team/b.txt", "b\n"),
        ]),
        missions: [
            Mission("Show your user ID and groups", hint: "Two letters.", solution: "id", check: .ranOK(#"^\s*(id|groups)\b"#)),
            Mission("Show who owns the files in team/", hint: "ls -l on the folder.", solution: "ls -l team", check: .ranOK(#"ls\s+.*-[a-zA-Z]*l.*team"#)),
            Mission("Change shared.txt's group to everyone", hint: "chgrp GROUP FILE.", solution: "chgrp everyone shared.txt", check: .group("shared.txt", "everyone")),
            Mission("Change the group of everything in team/ to everyone in one command", hint: "chgrp has a recursive option.", solution: "chgrp -R everyone team", check: .all([.group("team/a.txt", "everyone"), .group("team/b.txt", "everyone")])),
        ]
    )

    // MARK: - Scripting

    static let scripting = Category(
        id: "scripting", title: "Scripting", icon: "curlybraces",
        blurb: "Turn commands you repeat into scripts with variables, conditions, loops and functions, then schedule them.",
        lessons: [firstScript, variables, conditionals, loops, functions, cron]
    )

    static let firstScript = Lesson(
        id: "first-script",
        title: "Your first script",
        commands: ["#!", "chmod +x", "./", "$1"],
        topics: ["Shebang", "Comments", "Running scripts", "Arguments", "Exit codes"],
        summary: "A script is a text file full of commands. Add a shebang, make it executable, and you've built your own command.",
        sections: [
            S("Writing the file", """
            Any editor works. In the terminal, `nano hello.sh` is the friendliest: type, then **Ctrl+O** to save and **Ctrl+X** to quit. For short scripts you can also use a heredoc, which writes everything up to the `EOF` line into the file:
            """, example: Example("cat > hello.sh <<'EOF'\n#!/bin/bash\n# My first script\necho \"Hello from a script!\"\nEOF")),
            S("The shebang", """
            The first line, `#!/bin/bash`, tells the system which interpreter runs the file. `#!/usr/bin/env bash` finds bash on your `$PATH` instead, which is more portable. Every other line starting with `#` is a comment.
            """),
            S("Running it", """
            `bash hello.sh` runs it straight away. To run it as `./hello.sh`, first make it executable with `chmod +x hello.sh`. You need the `./` because bash only searches `$PATH` for commands, and the current folder isn't on it.
            """, example: Example("chmod +x hello.sh && ./hello.sh", output: "Hello from a script!")),
            S("Arguments and exit codes", """
            Inside a script, `$1`, `$2`, … are the arguments, `$@` is all of them, `$#` is how many there are, and `$0` is the script's name. `exit 0` signals success and any other number signals failure. Check the last command's code with `echo $?`.
            """, example: Example("./greet.sh Ada", output: "Hello, Ada")),
        ],
        reference: [
            O("#!/bin/bash", "Shebang: run with bash"),
            O("# comment", "Ignored by bash"),
            O("bash script.sh", "Run without chmod"),
            O("chmod +x script.sh", "Make executable"),
            O("./script.sh", "Run from this folder"),
            O("$1 $2 … / $@ / $#", "Arguments / all / count"),
            O("exit N", "Exit with status N (0 = success)"),
            O("echo $?", "Status of the last command"),
            O("set -euo pipefail", "Stop on errors and unset variables"),
        ],
        diagram: Diagram(
            "What ./hello.sh actually does",
            caption: "The kernel reads the #! line and starts a new bash process with your file as input. That bash runs the lines top to bottom, then exits with the status of the last command (or whatever you pass to exit).",
            nodes: [
                N("you", "./hello.sh Ada", icon: "person.fill", .actor, at: 0, 0),
                N("kernel", "Kernel", icon: "cpu", .system, at: 1, 0, detail: "reads #!/bin/bash"),
                N("bash", "new bash", icon: "terminal", .shell, at: 2, 0, detail: "child process"),
                N("script", "hello.sh", icon: "doc.plaintext", .file, at: 3, 0, detail: "line by line"),
                N("args", "$1 = Ada", icon: "list.number", .stream, at: 2, 1, detail: "$@, $#, $0"),
                N("out", "stdout + exit code", icon: "arrow.right.doc.on.clipboard", .stream, at: 3, 1, detail: "echo $? → 0"),
            ],
            edges: [
                E("you", "kernel", "exec"),
                E("kernel", "bash", "start"),
                E("bash", "script", "reads"),
                E("args", "bash", nil, dashed: true),
                E("script", "out", "runs"),
            ]
        ),
        missions: [
            Mission("Create hello.sh with a #!/bin/bash shebang and an echo", hint: "Use nano or the heredoc from the lesson.", solution: "cat > hello.sh <<'EOF'\n#!/bin/bash\necho \"Hello from a script!\"\nEOF", check: .matches("hello.sh", #"^#!\s*/(bin/bash|usr/bin/env\s+bash)"#)),
            Mission("Make hello.sh executable", hint: "chmod +x.", solution: "chmod +x hello.sh", check: .executable("hello.sh")),
            Mission("Run it with ./", hint: "./ then the file name.", solution: "./hello.sh", check: .ranOK(#"\./hello\.sh"#)),
            Mission("Write greet.sh that prints \"Hello, $1\" and run it with your name", hint: "Use \"$1\" inside the script. Run it with: bash greet.sh Ada", solution: "printf '#!/bin/bash\\necho \"Hello, $1\"\\n' > greet.sh\nbash greet.sh Ada", check: .all([.contains("greet.sh", "$1"), .ranOK(#"greet\.sh\s+\S+"#)])),
        ]
    )

    static let variables = Lesson(
        id: "variables",
        title: "Variables, types & operators",
        commands: ["VAR=", "$VAR", "$( )", "$(( ))"],
        topics: ["Variables", "Quoting", "Command substitution", "Arithmetic", "export", "read"],
        summary: "Store values in variables, capture command output, and do arithmetic. In bash everything is a string until you ask for math.",
        sections: [
            S("Assigning and reading", """
            `name="Ada"` creates a variable. There must be **no spaces around `=`**: `name = Ada` would try to run a command called `name`. Read it back with `$name`, or `${name}` when it touches other text: `${name}_backup`.

            By convention, environment variables are UPPERCASE and your own variables are lowercase.
            """, example: Example("name=\"Ada\"\necho \"Hello, $name\"", output: "Hello, Ada")),
            S("Quotes matter", """
            Double quotes expand variables: `"Hi $name"` gives `Hi Ada`. Single quotes keep everything literal: `'Hi $name'` gives `Hi $name`. Wrap variables in double quotes so values that contain spaces stay in one piece.
            """),
            S("Capturing output", """
            `$(command)` runs a command and drops its output into place: `today=$(date +%F)`. `${#name}` gives the length, and `${name:-guest}` falls back to `guest` when name is empty.
            """, example: Example("today=$(date +%F); echo \"Backup-$today.tar.gz\"", output: "Backup-2026-10-17.tar.gz")),
            S("Numbers and operators", """
            Bash variables are strings. `$(( ))` does integer arithmetic with `+ - * / %` and `**` for powers: `echo $((7 * 6))`. Compare numbers with `-eq -ne -lt -le -gt -ge` and strings with `=` and `!=`, which you'll use in the next lesson.

            `export NAME=value` passes a variable on to programs you start. Without export, only this shell sees it.
            """, example: Example("a=12; b=30; echo $((a + b))", output: "42")),
        ],
        reference: [
            O("name=value", "Assign (no spaces!)"),
            O("$name / ${name}", "Read a variable"),
            O("\"$name\" vs '$name'", "Double quotes expand, single don't"),
            O("$(cmd)", "Command substitution"),
            O("$((a + b))", "Integer arithmetic"),
            O("${#name}", "String length"),
            O("${name:-default}", "Fallback value"),
            O("export NAME=v", "Make visible to child processes"),
            O("read -p 'Q? ' ans", "Read user input"),
            O("env", "List environment variables"),
        ],
        diagram: Diagram(
            "From assignment to expansion",
            caption: "bash stores variables in its own table. Before running a command it expands $name, $(…) and $((…)), so the program only ever sees the final text.",
            nodes: [
                N("assign", "name=\"Ada\"", icon: "equal.square", .shell, at: 0, 0),
                N("table", "Shell variables", icon: "tablecells", .system, at: 1, 0, detail: "name=Ada  today=…"),
                N("line", "echo \"Hi $name\"", icon: "text.cursor", .shell, at: 0, 1, detail: "what you type"),
                N("expand", "Expansion", icon: "wand.and.stars", .shell, at: 1, 1, detail: "$name  $(…)  $((…))"),
                N("echo", "echo", icon: "gearshape", .process, at: 2, 1, detail: "receives: Hi Ada"),
                N("env", "Child processes", icon: "arrow.down.right.circle", .process, at: 2, 0, detail: "see only exported vars"),
            ],
            edges: [
                E("assign", "table", "stores"),
                E("line", "expand"),
                E("table", "expand", "looks up"),
                E("expand", "echo", "final args"),
                E("table", "env", "export", dashed: true),
            ]
        ),
        missions: [
            Mission("Store your city in a variable called city and echo it", hint: "city=\"Paris\", then echo \"$city\".", solution: "city=\"Pittsburgh\"\necho \"$city\"", check: .all([.ranOK(#"^\s*city=\S"#), .ranOK(#"echo\s+.*\$\{?city"#)])),
            Mission("Store today's date (YYYY-MM-DD) in a variable using $( )", hint: "date +%F prints YYYY-MM-DD.", solution: "today=$(date +%F)", check: .ranOK(#"=\$\(\s*date"#)),
            Mission("Calculate 17 × 23 with $(( ))", hint: "The multiplication operator is *.", solution: "echo $((17 * 23))", check: .ranOK(#"\$\(\(\s*17\s*\*\s*23\s*\)\)"#)),
            Mission("Write math.sh that sets a=12 and b=30, prints their sum, and save its output to sum.txt", hint: "Inside: echo $((a + b)). Then run: bash math.sh > sum.txt", solution: "printf 'a=12\\nb=30\\necho $((a + b))\\n' > math.sh\nbash math.sh > sum.txt", check: .all([.matches("sum.txt", #"^\s*42\s*$"#), .exists("math.sh", .file)])),
        ]
    )

    static let conditionals = Lesson(
        id: "conditionals",
        title: "Decisions: if, test & exit codes",
        commands: ["if", "[ ]", "&&", "||", "case"],
        topics: ["Exit status", "&& / ||", "if / else", "test [ ]", "[[ ]]", "case"],
        summary: "Every command reports success or failure. if, && and || use that to decide what runs next.",
        sections: [
            S("Exit status", """
            Every command exits with a number. **0 means success** and anything else means failure. `$?` holds the last one. This is the opposite of most languages, where 0 is false.
            """, example: Example("ls missing.txt; echo $?", output: "ls: missing.txt: No such file or directory\n1")),
            S("&& and ||", """
            `a && b` runs b only if a succeeded, and `a || b` runs b only if a failed. Together: `mkdir out && echo "created" || echo "failed"`.
            """, example: Example("mkdir reports && echo \"ready\"")),
            S("if / elif / else", """
            `if` runs a command and checks its exit status. Most of the time that command is `[ … ]` (also called `test`), which compares things. The spaces inside the brackets are required.

            Useful tests: `-f` (is a file), `-d` (is a directory), `-e` (exists), `-z` (string is empty), `=` and `!=` for strings, and `-eq -lt -gt -ge` for numbers. `[[ … ]]` is bash's safer version and also supports `&&` and `||` inside.
            """, example: Example("if [ -f config.ini ]; then\n  echo \"found\"\nelse\n  echo \"missing\"\nfi")),
            S("case", """
            When you'd otherwise write a long chain of `elif`s comparing one value, use `case`:
            """, example: Example("case \"$1\" in\n  start) echo \"starting\" ;;\n  stop)  echo \"stopping\" ;;\n  *)     echo \"usage: $0 start|stop\" ;;\nesac")),
        ],
        reference: [
            O("$?", "Exit status of the last command"),
            O("A && B", "Run B if A succeeded"),
            O("A || B", "Run B if A failed"),
            O("if CMD; then …; fi", "Branch on exit status"),
            O("[ -f F ] / [ -d D ]", "Is a file / directory"),
            O("[ -z \"$s\" ]", "String is empty"),
            O("[ \"$a\" = \"$b\" ]", "Strings are equal"),
            O("[ \"$n\" -ge 18 ]", "Number comparison"),
            O("[[ … ]]", "Bash test with && || and patterns"),
            O("case $x in a) …;; esac", "Match one value against patterns"),
        ],
        diagram: Diagram(
            "if [ -f config.ini ]",
            caption: "if doesn't check true or false. It runs the test command and branches on its exit status: 0 takes the then branch, and anything else takes else.",
            nodes: [
                N("start", "check.sh", icon: "play.circle", .shell, at: 0, 0),
                N("test", "[ -f config.ini ]", icon: "questionmark.diamond", .shell, at: 1, 0, detail: "the test command"),
                N("then", "then: echo found", icon: "checkmark.circle", .process, at: 2, 0, detail: "exit status 0"),
                N("else", "else: echo missing", icon: "xmark.circle", .process, at: 1, 1, detail: "exit status 1"),
                N("fi", "fi", icon: "stop.circle", .shell, at: 2, 1, detail: "continue script"),
            ],
            edges: [
                E("start", "test"),
                E("test", "then", "0"),
                E("test", "else", "≠ 0"),
                E("then", "fi"),
                E("else", "fi"),
            ]
        ),
        seed: Seed(files: [F("config.ini", "env=dev\n")]),
        missions: [
            Mission("Run a failing command, then print its exit status", hint: "ls something that doesn't exist, then echo $?.", solution: "ls nope; echo $?", check: .ran(#"echo\s+\$\?"#)),
            Mission("Use && so \"ready\" prints only if mkdir succeeds", hint: "mkdir DIR && echo ready.", solution: "mkdir reports && echo \"ready\"", check: .ran(#"mkdir\b.*&&\s*echo"#)),
            Mission("Write check.sh that prints found or missing for config.ini, and run it", hint: "Use if [ -f config.ini ]; then … else … fi. Run it with: bash check.sh", solution: "printf 'if [ -f config.ini ]; then\\n  echo found\\nelse\\n  echo missing\\nfi\\n' > check.sh\nbash check.sh", check: .all([.matches("check.sh", #"if\s+\[\[?\s+-[ef]\s"#), .ranOK(#"check\.sh"#)])),
            Mission("Write age.sh: print adult if $1 is 18 or more, else minor. Run it with a number.", hint: "if [ \"$1\" -ge 18 ]; then …", solution: "printf 'if [ \"$1\" -ge 18 ]; then\\n  echo adult\\nelse\\n  echo minor\\nfi\\n' > age.sh\nbash age.sh 21", check: .all([.matches("age.sh", #"-ge\s+18|-lt\s+18|-gt\s+17|>=\s*18|<\s*18"#), .ranOK(#"age\.sh\s+\d+"#)])),
        ]
    )

    static let loops = Lesson(
        id: "loops",
        title: "Loops: for & while",
        commands: ["for", "while", "read"],
        topics: ["for", "while", "until", "while read", "break / continue"],
        summary: "Repeat a command for every file, every line, or until a condition changes. Loops turn ten minutes of clicking into one line.",
        sections: [
            S("for each item", """
            `for x in a b c; do …; done` runs the body once for each word. The list can be a glob (`*.txt`), a range (`{1..5}`), or command output (`$(cat hosts.txt)`).
            """, example: Example("for i in {1..3}; do echo \"step $i\"; done", output: "step 1\nstep 2\nstep 3")),
            S("Looping over files", """
            Globs expand to the matching file names. Combine them with parameter expansion to rename in bulk: `${f%.JPG}` is `$f` with `.JPG` removed from the end.
            """, example: Example("for f in photos/*.JPG; do\n  mv \"$f\" \"${f%.JPG}.jpeg\"\ndone")),
            S("while", """
            `while condition; do …; done` repeats as long as the condition succeeds. The most common form reads a file line by line: `while read -r line; do …; done < file`. Use `break` to leave a loop early and `continue` to skip to the next round.
            """, example: Example("n=3\nwhile [ $n -gt 0 ]; do\n  echo $n\n  n=$((n - 1))\ndone")),
            S("C-style for", """
            Bash also supports `for ((i = 0; i < 5; i++)); do …; done` when you need a counter.
            """),
        ],
        reference: [
            O("for x in A B C; do …; done", "Loop over words"),
            O("for f in *.txt; do …; done", "Loop over files"),
            O("for i in {1..10}", "Loop over a range"),
            O("for ((i=0; i<5; i++))", "C-style counter loop"),
            O("while COND; do …; done", "Loop while COND succeeds"),
            O("while read -r line; do …; done < F", "Read F line by line"),
            O("break / continue", "Leave loop / skip to next"),
            O("${f%.ext}", "Remove .ext from the end of $f"),
        ],
        diagram: Diagram(
            "for f in photos/*.JPG",
            caption: "bash expands the glob into a list of names, then runs the body once per name with f set to it. When the list runs out, execution continues after done.",
            nodes: [
                N("glob", "photos/*.JPG", icon: "photo.on.rectangle", .file, at: 0, 0, detail: "expands to 5 names"),
                N("for", "for f in …", icon: "repeat", .shell, at: 1, 0, detail: "take next name"),
                N("body", "mv \"$f\" …", icon: "gearshape", .process, at: 2, 0, detail: "loop body"),
                N("done", "done", icon: "flag.checkered", .shell, at: 1, 1, detail: "list empty, continue"),
            ],
            edges: [
                E("glob", "for", "list"),
                E("for", "body", "f=IMG_001.JPG"),
                E("body", "for", "next item", dashed: true, loopBack: true),
                E("for", "done", "no items left"),
            ]
        ),
        seed: Seed(files: [
            F("photos/IMG_001.JPG", "photo 1\n"),
            F("photos/IMG_002.JPG", "photo 2\n"),
            F("photos/IMG_003.JPG", "photo 3\n"),
            F("photos/IMG_004.JPG", "photo 4\n"),
            F("photos/IMG_005.JPG", "photo 5\n"),
            F("servers.txt", "web-1.internal\nweb-2.internal\ndb-1.internal\n"),
        ]),
        missions: [
            Mission("Print the numbers 1 to 5 with a for loop", hint: "for i in {1..5}; do echo $i; done", solution: "for i in {1..5}; do echo $i; done", check: .ranOK(#"for\s+.*;\s*do\b|for\s*\(\("#)),
            Mission("Rename every photos/*.JPG to end in .jpeg instead", hint: "Loop over the glob and use ${f%.JPG}.jpeg as the new name.", solution: "for f in photos/*.JPG; do mv \"$f\" \"${f%.JPG}.jpeg\"; done", check: .all([.exists("photos/IMG_001.jpeg", .file), .exists("photos/IMG_005.jpeg", .file), .missing("photos/IMG_001.JPG")])),
            Mission("Print \"checking <host>\" for each line of servers.txt with while read", hint: "while read -r host; do …; done < servers.txt", solution: "while read -r host; do echo \"checking $host\"; done < servers.txt", check: .ranOK(#"while\s+.*read"#)),
            Mission("Write countdown.sh that counts 5 down to 1 with a while loop, and run it", hint: "Start at n=5 and loop while [ $n -gt 0 ].", solution: "printf 'n=5\\nwhile [ $n -gt 0 ]; do\\n  echo $n\\n  n=$((n - 1))\\ndone\\n' > countdown.sh\nbash countdown.sh", check: .all([.matches("countdown.sh", #"\bwhile\b"#), .ranOK(#"countdown\.sh"#)])),
        ]
    )

    static let functions = Lesson(
        id: "functions",
        title: "Functions & arrays",
        commands: ["name() { }", "local", "arr=( )"],
        topics: ["Functions", "local", "return", "Arrays", "source"],
        summary: "Group commands into reusable functions, and keep lists of values in arrays.",
        sections: [
            S("Defining functions", """
            `greet() { echo "Hello, $1"; }` defines a function, and `greet Ada` calls it like any other command. Inside a function, `$1`, `$2` and `$@` are the function's own arguments.

            Use `local` for variables so they don't leak into the rest of the script.
            """, example: Example("greet() {\n  local who=\"$1\"\n  echo \"Hello, $who\"\n}\ngreet Ada", output: "Hello, Ada")),
            S("Returning values", """
            `return N` sets the function's exit status (0 to 255) and is meant for success or failure. To pass data back, **echo it** and capture it: `msg=$(greet Ada)`.
            """),
            S("Arrays", """
            `fruits=(apple banana cherry)` creates an array. `${fruits[0]}` is the first item (indexes start at 0), `${fruits[@]}` is every item, `${#fruits[@]}` is the count, and `fruits+=(date)` appends.

            Loop over the items with `for f in "${fruits[@]}"`. The quotes keep items that contain spaces in one piece.
            """, example: Example("fruits=(apple banana cherry)\necho \"${fruits[1]} of ${#fruits[@]}\"", output: "banana of 3")),
        ],
        reference: [
            O("name() { …; }", "Define a function"),
            O("name arg1 arg2", "Call it"),
            O("local var=…", "Function-scoped variable"),
            O("return N", "Exit status of the function"),
            O("out=$(name)", "Capture what it echoes"),
            O("arr=(a b c)", "Create an array"),
            O("${arr[0]}", "First element"),
            O("${arr[@]}", "All elements"),
            O("${#arr[@]}", "Number of elements"),
            O("arr+=(d)", "Append"),
        ],
        macNote: "macOS's bash 3.2 doesn't support associative arrays (`declare -A`) or `mapfile`. Indexed arrays like the ones in this lesson work everywhere.",
        diagram: Diagram(
            "Calling a function and capturing its output",
            caption: "The function runs inside the current shell with its own $1. Whatever it echoes goes to stdout, and $( ) captures that into a variable.",
            nodes: [
                N("caller", "msg=$(greet Ada)", icon: "terminal", .shell, at: 0, 0, detail: "the caller"),
                N("fn", "greet()", icon: "function", .process, at: 1, 0, detail: "local who=$1"),
                N("args", "$1 = Ada", icon: "list.number", .stream, at: 1, 1, detail: "function args"),
                N("out", "stdout", icon: "arrow.right.doc.on.clipboard", .stream, at: 2, 0, detail: "Hello, Ada"),
                N("var", "msg", icon: "tray.full", .system, at: 2, 1, detail: "= \"Hello, Ada\""),
            ],
            edges: [
                E("caller", "fn", "call"),
                E("args", "fn", nil, dashed: true),
                E("fn", "out", "echo"),
                E("out", "var", "captured by $( )"),
            ]
        ),
        missions: [
            Mission("Define a function hello that echoes hi, then call it", hint: "hello() { echo hi; } and then hello", solution: "hello() { echo hi; }\nhello", check: .all([.ranOK(#"hello\s*\(\)\s*\{|function\s+hello"#), .ranOK(#"^\s*hello\s*$"#)])),
            Mission("Create an array of three colors and print the second one", hint: "Indexes start at 0, so the second is [1].", solution: "colors=(red green blue)\necho \"${colors[1]}\"", check: .ranOK(#"\$\{\w+\[1\]\}"#)),
            Mission("Print how many items the array has", hint: "${#name[@]}", solution: "echo ${#colors[@]}", check: .ranOK(#"\$\{#\w+\[@\]\}"#)),
            Mission("Write lib.sh with a shout function that upper-cases its argument, then source it and call shout", hint: "Inside: echo \"$1\" | tr a-z A-Z. Load it with: source lib.sh", solution: "printf 'shout() {\\n  echo \"$1\" | tr a-z A-Z\\n}\\n' > lib.sh\nsource lib.sh\nshout hello", check: .all([.matches("lib.sh", #"shout\s*\(\)|function\s+shout"#), .ranOK(#"^\s*shout\b"#)])),
        ]
    )

    static let cron = Lesson(
        id: "cron",
        title: "Scheduling with cron",
        commands: ["crontab", "cron"],
        topics: ["Cron syntax", "crontab", "launchd", "Logging"],
        summary: "cron runs commands on a schedule: backups every night, cleanup every hour. Five fields say when, the rest of the line says what.",
        sections: [
            S("The five fields", """
            A crontab line is `minute hour day-of-month month day-of-week command`. `*` means "every". `*/15` means "every 15", `1-5` is a range (Monday to Friday), and `1,15` is a list.
            """, example: Example("30 2 * * * /path/to/backup.sh   # every day at 02:30\n*/15 * * * 1-5 /path/to/sync.sh # every 15 min on weekdays")),
            S("Managing your crontab", """
            `crontab -l` lists your jobs, `crontab -e` edits them, and `crontab file` **replaces** your whole crontab with the file's contents. Run `crontab -l` first so you don't wipe existing jobs.
            """),
            S("Gotchas", """
            cron runs with a nearly empty environment, so use **absolute paths** for scripts and files. Output goes nowhere unless you redirect it: `… >> /tmp/backup.log 2>&1`. Test the script by hand before scheduling it.

            On macOS cron works, but it may need Full Disk Access to touch protected folders. Apple's native scheduler is `launchd`.
            """),
        ],
        reference: [
            O("m h dom mon dow cmd", "The five time fields, then the command"),
            O("*", "Every value"),
            O("*/15", "Every 15 units"),
            O("1-5", "Range (Mon to Fri in day-of-week)"),
            O("0,30", "List of values"),
            O("crontab -l", "List your jobs"),
            O("crontab -e", "Edit your jobs"),
            O("crontab FILE", "Replace your crontab with FILE"),
            O(">> log 2>&1", "Keep a log of each run"),
        ],
        macNote: "On macOS, cron may need Full Disk Access (System Settings → Privacy & Security) to reach some folders. The missions here only write crontab lines to a file, so nothing gets scheduled unless you install it yourself.",
        diagram: Diagram(
            "How cron decides to run a job",
            caption: "Every minute the cron daemon wakes up, reads each crontab line, and starts the command for any line whose five fields match the current time.",
            nodes: [
                N("clock", "Every minute", icon: "clock", .system, at: 0, 0),
                N("cron", "cron daemon", icon: "calendar.badge.clock", .process, at: 1, 0),
                N("tab", "crontab", icon: "doc.text", .file, at: 1, 1, detail: "30 2 * * * backup.sh"),
                N("match", "Fields match now?", icon: "questionmark.diamond", .shell, at: 2, 0, detail: "02:30, any day"),
                N("job", "backup.sh", icon: "gearshape.2", .process, at: 3, 0, detail: "minimal env"),
                N("log", "backup.log", icon: "doc.plaintext", .file, at: 3, 1, detail: ">> log 2>&1"),
            ],
            edges: [
                E("clock", "cron", "tick"),
                E("tab", "cron", "reads", dashed: true),
                E("cron", "match"),
                E("match", "job", "yes"),
                E("job", "log", "output"),
            ]
        ),
        seed: Seed(files: [
            F("backup.sh", "#!/bin/bash\nmkdir -p backups\ntar -czf \"backups/notes-$(date +%Y%m%d-%H%M%S).tar.gz\" notes\necho \"backup complete\"\n", mode: 0o755),
            F("notes/ideas.txt", "1. learn cron\n"),
        ]),
        missions: [
            Mission("Run backup.sh by hand first", hint: "Always test before scheduling.", solution: "./backup.sh", check: .ranOK(#"backup\.sh"#)),
            Mission("In my.cron, write a line that runs backup.sh every day at 02:30", hint: "minute=30, hour=2, then three stars.", solution: "echo \"30 2 * * * $PWD/backup.sh\" >> my.cron", check: .matches("my.cron", #"(?m)^\s*30\s+2\s+\*\s+\*\s+\*\s+\S*backup\.sh"#)),
            Mission("Add a line that runs it every 15 minutes, Monday to Friday", hint: "*/15 in the minute field, 1-5 in day-of-week.", solution: "echo \"*/15 * * * 1-5 $PWD/backup.sh\" >> my.cron", check: .matches("my.cron", #"(?m)^\s*\*/15\s+\*\s+\*\s+\*\s+(1-5|[Mm][Oo][Nn]-[Ff][Rr][Ii])\s+\S*backup\.sh"#)),
            Mission("List your current crontab (read-only, safe)", hint: "crontab with -l. \"no crontab\" is a fine answer.", solution: "crontab -l", check: .ran(#"crontab\s+-l"#)),
        ]
    )
}
