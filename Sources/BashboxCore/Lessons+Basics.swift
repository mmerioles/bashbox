import Foundation

extension Curriculum {
    // MARK: - Getting Started

    static let gettingStarted = Category(
        id: "getting-started", title: "Getting Started", icon: "flag",
        blurb: "What a shell is, how to read the prompt, and the shape of every command.",
        lessons: [theShell]
    )

    static let theShell = Lesson(
        id: "the-shell",
        title: "The shell & the prompt",
        commands: ["whoami", "date", "echo"],
        topics: ["What is Bash?", "CLI vs GUI", "Popular shells", "The prompt", "Tab completion", "Repeat commands", "Stop execution"],
        summary: "Bash is the program that reads what you type, finds the right program, and asks the operating system to run it. The terminal is just the window around it.",
        sections: [
            S("What is a shell?", """
            A **terminal** is the window. A **shell** is the program running inside it. Bash (the _Bourne Again SHell_) reads the line you type, works out which program you mean, asks the kernel to start it, and shows you what it prints.

            Everything you do in a terminal (opening files, starting servers, deploying code) goes through this loop: **read → find → run → show**.
            """),
            S("Reading the prompt", """
            The text before your cursor is the **prompt**. In Bashbox it looks like `bashbox ~/the-shell $`.

            `~/the-shell` is your **current directory** (`~` is short for your home folder). `$` means bash is ready for a command. A `#` instead of `$` means you are root, the all-powerful admin user, so be careful.
            """),
            S("Anatomy of a command", """
            Almost every command has the same shape: the **command name**, then **options** that change how it behaves (usually starting with `-`), then **arguments** that say what to act on.

            Spaces separate the pieces. If an argument contains a space, wrap it in quotes: `"my file.txt"`.
            """, example: Example("ls -l /usr/bin", output: "-rwxr-xr-x  1 root  wheel  154624 Sep 18 08:12 awk\n…")),
            S("Your first commands", """
            `whoami` prints your username. `date` prints the date and time. `echo` prints whatever you give it, which sounds useless until you start building scripts.

            Press **↑** to bring back earlier commands, and **Tab** to auto-complete names. These two keys save hours.
            """, example: Example("echo \"Hello, Bashbox\"", output: "Hello, Bashbox")),
            S("CLI vs GUI, and other shells", """
            A GUI makes you click through each step. On the command line (CLI) you describe the step once, and then you can repeat it, combine it with others, or script it. That's why servers, CI pipelines and containers are all driven from a shell.

            bash is one of several shells. **zsh** is the macOS default and mostly bash-compatible, **sh/dash** are minimal shells used for portable scripts, **fish** is friendly but not bash-compatible, and **PowerShell** is Windows' object-based shell. Learn bash and you can read nearly all of them.
            """),
            S("Shortcuts that save hours", """
            **Tab** completes names. **↑** recalls the last command, and `!!` reruns it (`sudo !!` reruns it as admin). **Ctrl+R** searches your history as you type.

            **Ctrl+C** stops whatever is running, **Ctrl+D** exits the shell, **Ctrl+L** clears the screen, and **Ctrl+A** / **Ctrl+E** jump to the start or end of the line.
            """, example: Example("sleep 30", output: "^C   ← press Ctrl+C to stop it")),
        ],
        reference: [
            O("whoami", "Print the current user's name"),
            O("date", "Print the current date and time"),
            O("echo TEXT", "Print TEXT followed by a newline"),
            O("clear", "Clear the screen (or press Ctrl+L)"),
            O("history", "List the commands you have run"),
            O("!!", "Run the previous command again"),
            O("Ctrl+R", "Search command history"),
            O("Ctrl+A / Ctrl+E", "Jump to start / end of line"),
            O("↑ / ↓", "Scroll through previous commands"),
            O("Tab", "Complete a command or file name"),
            O("Ctrl+C", "Stop the command that is running"),
            O("Ctrl+D", "Exit the shell (end of input)"),
        ],
        macNote: "macOS ships bash 3.2 at /bin/bash, while new Terminal windows default to zsh. Bashbox always runs bash, and everything in these lessons also works in zsh.",
        diagram: Diagram(
            "What happens when you press Enter",
            caption: "The terminal passes your keystrokes to bash. Bash asks the kernel to start the program, and the program's output (stdout) is drawn back in the terminal window.",
            nodes: [
                N("you", "You", icon: "person.fill", .actor, at: 0, 0, detail: "type date ⏎"),
                N("term", "Terminal", icon: "macwindow", .process, at: 1, 0, detail: "the window"),
                N("bash", "bash", icon: "terminal", .shell, at: 2, 0, detail: "parses the line"),
                N("kernel", "Kernel", icon: "cpu", .system, at: 3, 0, detail: "fork + exec"),
                N("prog", "/bin/date", icon: "gearshape", .process, at: 3, 1, detail: "the program"),
                N("stdout", "stdout", icon: "arrow.right.doc.on.clipboard", .stream, at: 2, 1, detail: "text output"),
                N("screen", "Screen", icon: "display", .process, at: 1, 1, detail: "Sat Oct 17 17:04"),
            ],
            groups: [G("Terminal app", ["term", "screen"]), G("Operating system", ["kernel", "prog"])],
            edges: [
                E("you", "term", "keystrokes"),
                E("term", "bash", "command line"),
                E("bash", "kernel", "run date"),
                E("kernel", "prog", "starts"),
                E("prog", "stdout", "writes"),
                E("stdout", "screen", "displayed"),
            ]
        ),
        missions: [
            Mission("Ask the shell who you are", hint: "There's a command that is literally the question.", solution: "whoami", check: .ranOK(#"^\s*whoami\b"#)),
            Mission("Print today's date and time", hint: "Four letters.", solution: "date", check: .ranOK(#"^\s*date\b"#)),
            Mission("Make bash say hello", hint: "Use echo and put your text in quotes.", solution: "echo \"Hello, Bashbox\"", check: .ranOK(#"^\s*echo\s+.*[Hh]ello"#)),
            Mission("Look back at what you've typed", hint: "bash remembers every command.", solution: "history", check: .ranOK(#"^\s*history\b"#)),
            Mission("Start sleep 10, then stop it early with Ctrl+C", hint: "Run sleep 10 and press Ctrl+C while it waits.", solution: "sleep 10", check: .ran(#"^\s*sleep\s+\d+\s*$"#)),
        ]
    )

    // MARK: - Basic Commands

    static let basics = Category(
        id: "basics", title: "Basic Commands", icon: "folder",
        blurb: "Move around the filesystem and create, read, copy, move and delete files.",
        lessons: [navigation, creatingFiles, managingFiles, gettingHelp]
    )

    static let navigation = Lesson(
        id: "navigation",
        title: "Moving around",
        commands: ["pwd", "ls", "cd"],
        topics: ["pwd", "ls", "cd", "Absolute vs relative paths", "Hidden files"],
        summary: "Your shell always has a current directory. pwd shows where you are, ls shows what's here, and cd takes you somewhere else.",
        sections: [
            S("Where am I?", """
            `pwd` (_print working directory_) prints the full path of the folder you are in. Paths start at `/`, the root of the filesystem, and each `/` goes one folder deeper.
            """, example: Example("pwd", output: "/Users/you/Library/Application Support/Bashbox/home/navigation")),
            S("What's in here?", """
            `ls` lists the current folder. Add options to see more: `-l` gives the long format (permissions, owner, size, date), `-a` shows hidden files (names starting with `.`), and `-h` prints sizes like `4.0K` instead of `4096`. Options combine: `ls -lah`.

            You can also list another folder without going there: `ls projects`.
            """, example: Example("ls -la", output: "drwxr-xr-x  6 you  staff  192 Oct 17 09:00 .\n-rw-r--r--  1 you  staff   23 Oct 17 09:00 .secret-config\ndrwxr-xr-x  4 you  staff  128 Oct 17 09:00 projects")),
            S("Changing directory", """
            `cd projects` moves into `projects`. `cd ..` goes up one level, `cd ~` (or just `cd`) goes home, and `cd -` jumps back to wherever you were before.

            A path that starts with `/` is **absolute**, meaning it starts from the root. Anything else is **relative** to where you are now. `.` means "this folder" and `..` means "the parent folder".
            """, example: Example("cd projects/website && pwd", output: "…/navigation/projects/website")),
            S("Let Tab do the typing", """
            Type `cd pro` and press **Tab**: bash completes it to `projects/`. Press Tab twice to see every option when more than one name matches.
            """),
        ],
        reference: [
            O("pwd", "Print the current directory"),
            O("ls", "List files in the current directory"),
            O("ls -l", "Long format: permissions, owner, size, modified time"),
            O("ls -a", "Include hidden files (names starting with .)"),
            O("ls -h", "Human-readable sizes (with -l)"),
            O("ls -t", "Sort by modification time, newest first"),
            O("ls -R", "List subdirectories recursively"),
            O("cd DIR", "Change into DIR"),
            O("cd ..", "Go up one directory"),
            O("cd ~  /  cd", "Go to your home directory"),
            O("cd -", "Go back to the previous directory"),
        ],
        macNote: "In Bashbox, ~ is a sandbox home folder inside Application Support, so `cd ~` never takes you into your real files. Each lesson gets its own folder inside it.",
        diagram: Diagram(
            "Your lesson workspace as a tree",
            caption: "Each cd moves you one edge along the tree. `..` walks back towards the root, and pwd prints the path from / down to where you stand.",
            nodes: [
                N("home", "~", icon: "house", .file, at: 0, 1, detail: "sandbox home"),
                N("nav", "navigation/", icon: "folder", .file, at: 1, 1, detail: "you start here"),
                N("projects", "projects/", icon: "folder", .file, at: 2, 0),
                N("notes", "notes/", icon: "folder", .file, at: 2, 2),
                N("website", "website/", icon: "folder", .file, at: 3, 0),
                N("api", "api/", icon: "folder", .file, at: 3, 1),
                N("css", "css/", icon: "folder.fill", .file, at: 4, 0, detail: "cd projects/website/css"),
                N("todo", "todo.txt", icon: "doc.text", .file, at: 3, 2),
            ],
            groups: [G("Lesson workspace", ["nav", "projects", "notes", "website", "api", "css", "todo"])],
            edges: [
                E("home", "nav", "cd navigation"),
                E("nav", "projects"),
                E("nav", "notes"),
                E("projects", "website"),
                E("projects", "api"),
                E("website", "css"),
                E("notes", "todo"),
            ]
        ),
        seed: Seed(
            directories: ["projects/website/css", "projects/api", "notes"],
            files: [
                F("README.md", "# Navigation practice\nExplore the folders with ls and cd.\n"),
                F(".secret-config", "token=you-found-the-hidden-file\n"),
                F("notes/todo.txt", "- learn cd\n- learn ls\n"),
                F("projects/website/index.html", "<h1>Hello</h1>\n"),
                F("projects/website/css/style.css", "h1 { color: rebeccapurple; }\n"),
                F("projects/api/server.py", "print('api running')\n"),
            ]
        ),
        missions: [
            Mission("Print your working directory", hint: "Three letters: print working directory.", solution: "pwd", check: .ranOK(#"^\s*pwd\b"#)),
            Mission("List everything here, including hidden files", hint: "ls has an option for 'all'.", solution: "ls -la", check: .ranOK(#"^\s*ls\s+(.*\s)?-[a-zA-Z]*a"#)),
            Mission("Go into projects/website/css and run pwd there", hint: "cd accepts a whole path at once. Use Tab to complete each folder.", solution: "cd projects/website/css\npwd", check: .ranIn(#"^\s*pwd\b"#, "projects/website/css")),
            Mission("Jump up two levels in one command", hint: "Each .. is one level up. Join them with /.", solution: "cd ../..", check: .ranOK(#"cd\s+\.\./\.\."#)),
        ]
    )

    static let creatingFiles = Lesson(
        id: "creating-files",
        title: "Creating & reading files",
        commands: ["touch", "mkdir", "echo", "cat"],
        topics: ["touch", "mkdir", "echo", "cat", "less"],
        summary: "Make empty files and folders, write text into files with redirection, and print them back out.",
        sections: [
            S("Empty files and folders", """
            `touch notes.txt` creates an empty file, or updates the timestamp if the file already exists. `mkdir drafts` creates a folder.

            `mkdir -p a/b/c` creates the whole chain at once and doesn't complain if parts of it already exist.
            """, example: Example("mkdir -p journal/2026/october")),
            S("Writing with redirection", """
            `echo` prints to the screen, but `>` sends that output into a file instead. **`>` replaces the file's contents.** Use `>>` to add to the end.

            This works with any command, not just echo: `ls > listing.txt` saves a directory listing.
            """, example: Example("echo \"buy milk\" > todo.txt\necho \"call mom\" >> todo.txt")),
            S("Reading files", """
            `cat` (_concatenate_) prints a file. Give it several files and it prints them one after another, which is where the name comes from. `cat -n` numbers the lines.

            For long files, use `less file` to scroll (press `q` to quit).
            """, example: Example("cat -n todo.txt", output: "     1\tbuy milk\n     2\tcall mom")),
        ],
        reference: [
            O("touch FILE", "Create an empty file or update its timestamp"),
            O("mkdir DIR", "Create a directory"),
            O("mkdir -p A/B/C", "Create nested directories"),
            O("echo TEXT > FILE", "Write TEXT to FILE (overwrites)"),
            O("echo TEXT >> FILE", "Append TEXT to FILE"),
            O("cat FILE", "Print a file"),
            O("cat A B > C", "Join A and B into C"),
            O("cat -n FILE", "Print with line numbers"),
            O("less FILE", "Scroll through a file (q to quit)"),
        ],
        diagram: Diagram(
            "Output can go to the screen or into a file",
            caption: "Without redirection, echo writes to the terminal. `>` points its stdout at a file instead (replacing it), and `>>` appends. cat reads the file and writes it back to stdout.",
            nodes: [
                N("echo", "echo \"buy milk\"", icon: "text.bubble", .process, at: 0, 0),
                N("redir", "> or >>", icon: "arrow.right.to.line", .stream, at: 1, 0, detail: "redirect stdout"),
                N("file", "todo.txt", icon: "doc.text", .file, at: 2, 0, detail: "on disk"),
                N("cat", "cat todo.txt", icon: "doc.text.magnifyingglass", .process, at: 2, 1),
                N("screen", "Terminal", icon: "display", .process, at: 1, 1),
            ],
            edges: [
                E("echo", "redir", "stdout"),
                E("redir", "file", "writes"),
                E("file", "cat", "reads"),
                E("cat", "screen", "stdout"),
            ]
        ),
        seed: Seed(files: [
            F("welcome.txt", "Welcome to Bashbox!\nThis file has a few lines.\nRead it with cat.\nNumber the lines with cat -n.\n"),
        ]),
        missions: [
            Mission("Create an empty file named notes.txt", hint: "The command is named after updating a file's timestamp.", solution: "touch notes.txt", check: .exists("notes.txt", .file)),
            Mission("Create journal/2026/october in one command", hint: "mkdir needs an option to create parent folders.", solution: "mkdir -p journal/2026/october", check: .exists("journal/2026/october", .directory)),
            Mission("Write \"buy milk\" into todo.txt", hint: "echo plus a single >.", solution: "echo \"buy milk\" > todo.txt", check: .contains("todo.txt", "buy milk")),
            Mission("Add \"call mom\" to todo.txt without erasing it", hint: "A single > overwrites the file. Two of them append.", solution: "echo \"call mom\" >> todo.txt", check: .all([.contains("todo.txt", "buy milk"), .contains("todo.txt", "call mom")])),
            Mission("Print welcome.txt with line numbers", hint: "cat has an option for numbering lines.", solution: "cat -n welcome.txt", check: .ranOK(#"cat\s+-n\s+.*welcome"#)),
        ]
    )

    static let managingFiles = Lesson(
        id: "managing-files",
        title: "Copy, move & delete",
        commands: ["cp", "mv", "rm"],
        topics: ["cp", "mv", "rm", "rmdir", "Wildcards"],
        summary: "Duplicate files with cp, move or rename them with mv, and delete them with rm. rm has no trash can.",
        sections: [
            S("Copying", """
            `cp source destination` copies a file. If the destination is a folder, the copy keeps its name and goes inside it. Copying a folder needs `-r` (_recursive_): `cp -r photos photos-backup`.
            """, example: Example("cp report-draft.txt backup/")),
            S("Moving and renaming", """
            `mv` does both jobs: `mv old.txt new.txt` renames a file, and `mv file.txt archive/` moves it. Unlike cp, it works on folders without any options.
            """, example: Example("mv report-draft.txt report-final.txt")),
            S("Deleting, carefully", """
            `rm file` deletes a file **permanently**. There is no trash can and no undo. `rm -r folder` deletes a folder and everything in it. `rm -i` asks before each deletion, which is a good habit while you're learning.

            Wildcards let one command match many files: `rm *.tmp` removes every file ending in `.tmp`. Run `ls *.tmp` first to see exactly what will be deleted.
            """, example: Example("ls *.tmp && rm -i *.tmp")),
        ],
        reference: [
            O("cp SRC DST", "Copy a file"),
            O("cp -r SRC DST", "Copy a directory and its contents"),
            O("cp -i SRC DST", "Ask before overwriting"),
            O("mv SRC DST", "Move or rename"),
            O("rm FILE", "Delete a file (permanent)"),
            O("rm -r DIR", "Delete a directory recursively"),
            O("rm -i FILE", "Ask before each deletion"),
            O("rmdir DIR", "Delete an empty directory"),
            O("*.ext", "Wildcard: every name ending in .ext"),
        ],
        diagram: Diagram(
            "One file, three fates",
            caption: "cp leaves the original in place and makes a second copy. mv keeps the same data under a new name or location. rm removes it with no way back.",
            nodes: [
                N("draft", "report-draft.txt", icon: "doc.text", .file, at: 0, 1),
                N("copy", "backup/report-draft.txt", icon: "doc.on.doc", .file, at: 2, 0, detail: "original still exists"),
                N("moved", "report-final.txt", icon: "pencil", .file, at: 2, 1, detail: "same data, new name"),
                N("gone", "Gone", icon: "trash.slash", .system, at: 2, 2, detail: "no trash, no undo"),
            ],
            edges: [
                E("draft", "copy", "cp"),
                E("draft", "moved", "mv"),
                E("draft", "gone", "rm", dashed: true),
            ]
        ),
        seed: Seed(
            directories: ["photos", "old-logs"],
            files: [
                F("report-draft.txt", "Q3 report: draft\n"),
                F("photos/beach.jpg", "(pretend this is a photo of a beach)\n"),
                F("photos/cat.jpg", "(pretend this is a photo of a cat)\n"),
                F("old-logs/app-2024.log", "old\n"),
                F("old-logs/app-2025.log", "old\n"),
                F("cache.tmp", "temporary\n"),
                F("session.tmp", "temporary\n"),
            ]
        ),
        missions: [
            Mission("Create backup/ and copy report-draft.txt into it", hint: "mkdir first, then cp the file into the folder.", solution: "mkdir backup\ncp report-draft.txt backup/", check: .exists("backup/report-draft.txt", .file)),
            Mission("Rename report-draft.txt to report-final.txt", hint: "Renaming is moving to a new name.", solution: "mv report-draft.txt report-final.txt", check: .all([.exists("report-final.txt", .file), .missing("report-draft.txt")])),
            Mission("Copy the whole photos folder to photos-backup", hint: "Copying a folder needs the recursive option.", solution: "cp -r photos photos-backup", check: .all([.exists("photos-backup/beach.jpg", .file), .exists("photos-backup/cat.jpg", .file)])),
            Mission("Delete every .tmp file with one command", hint: "Use a * wildcard. Check it with ls first.", solution: "rm *.tmp", check: .all([.missing("cache.tmp"), .missing("session.tmp")])),
            Mission("Delete old-logs and everything inside it", hint: "rm needs -r for folders.", solution: "rm -r old-logs", check: .missing("old-logs")),
        ]
    )

    static let gettingHelp = Lesson(
        id: "getting-help",
        title: "Getting help & aliases",
        commands: ["man", "type", "alias"],
        topics: ["man", "--help", "type", "which", "alias", "~/.bashrc"],
        summary: "Every command comes with a manual. Learn to read it, find out what a command actually is, and create shortcuts for the commands you type all the time.",
        sections: [
            S("Read the manual", """
            `man ls` opens the manual page for ls. Use **Space** to page down, **b** to page up, **/word** to search, **n** for the next match, and **q** to quit.

            Many tools also print a short summary with `--help`. On macOS the built-in BSD tools often don't support it, so reach for `man` there.
            """, example: Example("man ls")),
            S("What is this command, really?", """
            A name you type can be an **alias**, a **builtin** that lives inside bash (like `cd`), or a **program** on disk found through your `$PATH`. `type name` tells you which. `which name` shows where a program lives.
            """, example: Example("type cd ls", output: "cd is a shell builtin\nls is /bin/ls")),
            S("Aliases", """
            An alias is a shortcut: `alias ll='ls -lah'` makes `ll` run `ls -lah`. Run `alias` on its own to list them and `unalias ll` to remove one.

            Aliases disappear when the shell exits. To keep one, add the line to `~/.bashrc`, which bash reads at startup. In Bashbox that file lives in your sandbox home.
            """, example: Example("echo \"alias ll='ls -lah'\" >> ~/.bashrc")),
        ],
        reference: [
            O("man CMD", "Open the manual for CMD (q to quit)"),
            O("CMD --help", "Short usage summary (GNU tools)"),
            O("type NAME", "Is NAME an alias, builtin, or program?"),
            O("which NAME", "Path to the program that would run"),
            O("alias", "List aliases"),
            O("alias ll='ls -lah'", "Create an alias"),
            O("unalias ll", "Remove an alias"),
            O("source ~/.bashrc", "Reload your startup file"),
            O("echo $PATH", "Folders bash searches for programs"),
        ],
        diagram: Diagram(
            "How bash finds what to run",
            caption: "When you type a name, bash checks aliases first, then its own builtins, then each folder in $PATH from left to right. The first match wins.",
            nodes: [
                N("input", "ll", icon: "keyboard", .actor, at: 0, 0, detail: "you type a name"),
                N("alias", "Aliases", icon: "arrow.triangle.branch", .shell, at: 1, 0, detail: "ll → ls -lah"),
                N("builtin", "Builtins", icon: "terminal", .shell, at: 2, 0, detail: "cd, echo, type…"),
                N("path", "$PATH", icon: "folder", .file, at: 3, 0, detail: "/usr/bin:/bin:…"),
                N("prog", "/bin/ls", icon: "gearshape", .process, at: 4, 0, detail: "runs with -lah"),
                N("rc", "~/.bashrc", icon: "doc.text", .file, at: 1, 1, detail: "aliases saved here"),
            ],
            groups: [G("bash lookup order", ["alias", "builtin", "path"])],
            edges: [
                E("input", "alias", "1"),
                E("alias", "builtin", "2"),
                E("builtin", "path", "3"),
                E("path", "prog", "found"),
                E("rc", "alias", "loaded at startup", dashed: true),
            ]
        ),
        missions: [
            Mission("Open the manual page for ls (press q to quit)", hint: "man followed by the command name.", solution: "man ls", check: .ran(#"^\s*man\s+ls\b"#)),
            Mission("Find out what kind of command cd is", hint: "One builtin tells you how bash sees a name.", solution: "type cd", check: .ranOK(#"^\s*type\s+(.*\s)?cd\b"#)),
            Mission("Create an alias ll that runs ls -lah, then use it", hint: "alias name='command'. No spaces around the =.", solution: "alias ll='ls -lah'\nll", check: .all([.ranOK(#"^\s*alias\s+ll=.*ls"#), .ranOK(#"^\s*ll\b"#)])),
            Mission("Save the alias in ~/.bashrc so it survives restarts", hint: "Append the alias line to ~/.bashrc with >>.", solution: "echo \"alias ll='ls -lah'\" >> ~/.bashrc", check: .matches("../.bashrc", #"alias\s+ll="#)),
        ]
    )
}
