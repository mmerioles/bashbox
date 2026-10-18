import Foundation

extension Curriculum {
    // MARK: - System Monitoring

    static let systemMonitoring = Category(
        id: "system", title: "System Monitoring", icon: "gauge.with.dots.needle.33percent",
        blurb: "See what's running, stop what's stuck, and find out where your disk and memory went.",
        lessons: [processes, resources]
    )

    static let processes = Lesson(
        id: "processes",
        title: "Processes & jobs",
        commands: ["ps", "top", "kill", "jobs"],
        topics: ["ps", "top", "kill", "pkill", "jobs", "fg / bg", "Signals"],
        summary: "Every running program is a process with an ID (PID). List them, watch them live, run them in the background, and stop them.",
        sections: [
            S("Listing processes", """
            `ps` on its own shows the processes started from this terminal. `ps aux` shows every process on the machine, with its user, PID, CPU and memory use. Pipe it to grep to find one: `ps aux | grep Chrome`.

            `pgrep -l name` is a shortcut that prints the PIDs of matching processes.
            """, example: Example("ps aux | head -n 3", output: "USER   PID  %CPU %MEM  …  COMMAND\nroot     1   0.0  0.1  …  /sbin/launchd\n…")),
            S("Watching live", """
            `top` shows a live view that refreshes every second. On macOS, `top -o cpu` sorts by CPU and `top -l 1 | head -n 15` prints one snapshot and exits. Press **q** to quit.
            """),
            S("Background jobs", """
            End a command with `&` to run it in the background and get your prompt back right away. `jobs` lists background jobs. `fg %1` brings job 1 back to the foreground, **Ctrl+Z** pauses the foreground job, and `bg` resumes it in the background.
            """, example: Example("sleep 300 &", output: "[1] 48213")),
            S("Stopping processes", """
            `kill PID` politely asks a process to stop by sending it SIGTERM. If it ignores you, `kill -9 PID` (SIGKILL) ends it immediately, with no chance to clean up. `kill %1` targets a job number, and `pkill name` targets processes by name.
            """, example: Example("kill %1", output: "[1]+  Terminated: 15          sleep 300")),
        ],
        reference: [
            O("ps", "Processes in this terminal"),
            O("ps aux", "Every process, with CPU/memory"),
            O("pgrep -l NAME", "PIDs of processes matching NAME"),
            O("top -o cpu", "Live view sorted by CPU (macOS)"),
            O("CMD &", "Run CMD in the background"),
            O("jobs", "List background jobs"),
            O("fg %N / bg %N", "Foreground / background job N"),
            O("Ctrl+Z", "Pause the foreground job"),
            O("kill PID", "Ask a process to stop (SIGTERM)"),
            O("kill -9 PID", "Force-stop a process (SIGKILL)"),
            O("pkill NAME", "Stop processes by name"),
        ],
        macNote: "macOS's top uses different flags from Linux's: `top -o cpu` sorts by CPU and `top -l 1` takes a single snapshot. `ps aux` works the same on both.",
        diagram: Diagram(
            "Starting and stopping a background job",
            caption: "bash starts `sleep 300 &` as a child process and gives you the prompt back. `kill` asks the kernel to deliver SIGTERM to that PID. ps reads the kernel's process table.",
            nodes: [
                N("you", "You", icon: "person.fill", .actor, at: 0, 0, detail: "sleep 300 &"),
                N("bash", "bash", icon: "terminal", .shell, at: 1, 0, detail: "PID 41200"),
                N("sleep", "sleep 300", icon: "moon.zzz", .process, at: 3, 0, detail: "PID 48213, job [1]"),
                N("kernel", "Kernel", icon: "cpu", .system, at: 2, 1, detail: "process table"),
                N("ps", "ps aux", icon: "list.bullet.rectangle", .process, at: 2, 2, detail: "reads the table"),
                N("signal", "SIGTERM (15)", icon: "bolt", .stream, at: 3, 1, detail: "-9 = SIGKILL"),
            ],
            edges: [
                E("you", "bash", "command"),
                E("bash", "sleep", "fork + exec (&)"),
                E("bash", "kernel", "kill 48213"),
                E("kernel", "ps", "process list"),
                E("kernel", "signal"),
                E("signal", "sleep", "delivered"),
            ]
        ),
        missions: [
            Mission("List every process running on your Mac", hint: "ps with the a, u and x options.", solution: "ps aux", check: .ranOK(#"^\s*ps\s+(.*\s)?-?(aux|ax|-e|-A)"#)),
            Mission("Start sleep 300 in the background", hint: "End the command with &.", solution: "sleep 300 &", check: .ran(#"sleep\s+\d+\s*&"#)),
            Mission("List your background jobs", hint: "A four-letter builtin.", solution: "jobs", check: .ranOK(#"^\s*jobs\b"#)),
            Mission("Stop the sleep with kill", hint: "kill %1 targets job 1, or use the PID from jobs -l.", solution: "kill %1", check: .ran(#"^\s*(kill|pkill)\b"#)),
            Mission("Take a one-time snapshot of top", hint: "macOS top takes -l 1 for a single sample.", solution: "top -l 1 | head -n 15", check: .ran(#"^\s*top\b"#)),
        ]
    )

    static let resources = Lesson(
        id: "resources",
        title: "Disk, memory & uptime",
        commands: ["df", "du", "free", "uptime"],
        topics: ["df", "du", "free / vm_stat", "uptime", "Load average"],
        summary: "Find out how much disk is free, which folder is eating it, how memory is doing, and how long the machine has been up.",
        sections: [
            S("Disk space: df", """
            `df -h` lists every mounted filesystem with its size, used and available space, in human-readable units. When something says "disk full", start here.
            """, example: Example("df -h /", output: "Filesystem      Size   Used  Avail Capacity  Mounted on\n/dev/disk3s1s1  460Gi   11Gi  210Gi     6%    /")),
            S("Folder sizes: du", """
            df tells you a disk is full, and du tells you why. `du -sh folder` prints one total for a folder. `du -h -d 1` prints a total for each folder one level down, and adding `| sort -h` puts the biggest last.
            """, example: Example("du -h -d 1 data | sort -h")),
            S("Memory", """
            On Linux, `free -h` shows used and free RAM. macOS doesn't have free. Use `vm_stat` for page counts, `top -l 1 | grep PhysMem` for a one-line summary, or `sysctl hw.memsize` for total RAM in bytes.
            """, example: Example("top -l 1 | grep PhysMem", output: "PhysMem: 15G used (2104M wired), 870M unused.")),
            S("Uptime and load", """
            `uptime` shows how long the machine has been running, how many users are logged in, and the **load average** over the last 1, 5 and 15 minutes. Load is roughly how many processes want the CPU; compare it to your core count.
            """),
        ],
        reference: [
            O("df -h", "Free space on every filesystem"),
            O("du -sh DIR", "Total size of DIR"),
            O("du -h -d 1 DIR", "Size of each subfolder (macOS)"),
            O("du -h --max-depth=1", "Same thing on Linux"),
            O("sort -h", "Sort human-readable sizes"),
            O("free -h", "Memory usage (Linux only)"),
            O("vm_stat", "Memory page statistics (macOS)"),
            O("sysctl hw.memsize", "Total RAM in bytes (macOS)"),
            O("uptime", "Time since boot and load average"),
        ],
        macNote: "There's no `free` on macOS: use `vm_stat` or `top -l 1 | grep PhysMem`. BSD du uses `-d 1` where GNU du uses `--max-depth=1`.",
        diagram: Diagram(
            "Where df and du get their numbers",
            caption: "df asks the filesystem for totals, which is fast. du walks every file under a folder and adds up the sizes, which is slower but shows you where the space went.",
            nodes: [
                N("df", "df -h", icon: "internaldrive", .process, at: 0, 0),
                N("volume", "/ (APFS volume)", icon: "externaldrive", .system, at: 1, 0, detail: "size, used, avail"),
                N("du", "du -h -d 1 data", icon: "chart.pie", .process, at: 0, 1),
                N("data", "data/", icon: "folder", .file, at: 1, 1, detail: "walks every file"),
                N("logs", "logs/", icon: "folder.fill", .file, at: 2, 1, detail: "biggest"),
                N("images", "images/", icon: "folder", .file, at: 2, 2),
                N("cache", "cache/", icon: "folder", .file, at: 1, 2),
                N("mem", "vm_stat", icon: "memorychip", .process, at: 2, 0, detail: "RAM pages (macOS)"),
            ],
            groups: [G("Disk", ["volume", "data", "logs", "images", "cache"])],
            edges: [
                E("df", "volume", "asks for totals"),
                E("du", "data", "walks"),
                E("data", "logs"),
                E("data", "images"),
                E("data", "cache"),
                E("mem", "volume", "memory, not disk", dashed: true),
            ]
        ),
        seed: Seed(files: [
            F("data/logs/app.log", SeedData.filler("log", kilobytes: 400)),
            F("data/logs/worker.log", SeedData.filler("log", kilobytes: 200)),
            F("data/images/logo.svg", SeedData.filler("svg", kilobytes: 60)),
            F("data/images/banner.svg", SeedData.filler("svg", kilobytes: 90)),
            F("data/cache/session.json", SeedData.filler("cache", kilobytes: 30)),
        ]),
        missions: [
            Mission("Show free disk space in human-readable units", hint: "df with -h.", solution: "df -h", check: .ranOK(#"^\s*df\b.*-[a-zA-Z]*h"#)),
            Mission("Print the total size of the data folder", hint: "du with -s (summary) and -h.", solution: "du -sh data", check: .ranOK(#"du\b.*-[a-zA-Z]*s.*data"#)),
            Mission("Find the biggest folder inside data/ and write its name to answer.txt", hint: "du -h -d 1 data | sort -h, then echo the name > answer.txt.", solution: "du -h -d 1 data | sort -h\necho logs > answer.txt", check: .matches("answer.txt", "(?i)logs")),
            Mission("Check memory usage the macOS way", hint: "free doesn't exist here. Try vm_stat.", solution: "vm_stat", check: .ran(#"^\s*(vm_stat|free|top\s+-l|sysctl\s+hw\.mem)"#)),
            Mission("Find out how long your Mac has been running", hint: "The command is the word itself.", solution: "uptime", check: .ranOK(#"^\s*uptime\b"#)),
        ]
    )

    // MARK: - Networking

    static let networking = Category(
        id: "networking", title: "Networking", icon: "network",
        blurb: "Check connectivity, call HTTP APIs, and work with remote machines over SSH.",
        lessons: [web, remote]
    )

    static let web = Lesson(
        id: "web",
        title: "ping, curl & wget",
        commands: ["ping", "curl", "wget"],
        topics: ["ping", "curl", "wget", "DNS", "HTTP"],
        summary: "Check whether a host is reachable, fetch pages and APIs from the command line, and download files.",
        sections: [
            S("Is it reachable? ping", """
            `ping host` sends small packets and reports how long each round trip takes. On macOS it runs until you press **Ctrl+C**, so use `-c 3` to send three and stop.
            """, example: Example("ping -c 3 127.0.0.1", output: "64 bytes from 127.0.0.1: icmp_seq=0 ttl=64 time=0.041 ms\n…\n3 packets transmitted, 3 packets received, 0.0% packet loss")),
            S("curl: talk HTTP", """
            `curl URL` prints the response body. You'll use these options all the time: `-o file` saves to a file, `-O` saves using the remote name, `-I` fetches headers only, `-L` follows redirects, `-s` hides the progress bar, and `-v` shows everything.

            curl speaks to APIs too: `curl -s https://api.github.com/repos/mmerioles/bashbox`. Send data with `-X POST -H 'Content-Type: application/json' -d '{"a":1}'`.
            """, example: Example("curl -I https://example.com", output: "HTTP/2 200\ncontent-type: text/html\n…")),
            S("wget", """
            `wget URL` downloads a file to the current folder, and `wget -r` can mirror whole sites. It isn't installed on macOS by default (`brew install wget` adds it), and `curl -O URL` does the same basic job.
            """),
        ],
        reference: [
            O("ping -c N HOST", "Send N pings and stop"),
            O("curl URL", "Print the response body"),
            O("curl -o FILE URL", "Save to FILE"),
            O("curl -O URL", "Save using the remote file name"),
            O("curl -I URL", "Headers only"),
            O("curl -L URL", "Follow redirects"),
            O("curl -s URL", "Silent (no progress bar)"),
            O("curl -X POST -d DATA", "Send a POST request"),
            O("wget URL", "Download a file (brew install wget)"),
        ],
        macNote: "wget isn't installed on macOS. Use `curl -O URL`, or install wget with Homebrew. ping on macOS runs until Ctrl+C unless you pass -c.",
        diagram: Diagram(
            "What curl does for one request",
            caption: "curl turns the hostname into an IP address with DNS, opens a TLS connection, sends an HTTP request, and writes the response body to stdout, or to a file with -o.",
            nodes: [
                N("curl", "curl -o page.html", icon: "arrow.down.circle", .process, at: 0, 0, detail: "https://example.com"),
                N("dns", "DNS", icon: "signpost.right", .network, at: 1, 1, detail: "example.com → IP"),
                N("server", "example.com:443", icon: "server.rack", .network, at: 2, 0, detail: "web server"),
                N("resp", "HTTP/2 200", icon: "envelope.open", .stream, at: 3, 0, detail: "headers + body"),
                N("file", "page.html", icon: "doc.richtext", .file, at: 3, 1, detail: "-o writes here"),
            ],
            groups: [G("The internet", ["dns", "server"])],
            edges: [
                E("curl", "dns", "1. resolve"),
                E("curl", "server", "2. GET / over TLS"),
                E("server", "resp", "3. response"),
                E("resp", "file", "4. body"),
            ]
        ),
        missions: [
            Mission("Ping your own machine exactly 3 times", hint: "127.0.0.1 is always you. Use -c to set the count.", solution: "ping -c 3 127.0.0.1", check: .ran(#"ping\s+.*-c\s*3"#)),
            Mission("Fetch only the headers of https://example.com", hint: "curl's capital-I option.", solution: "curl -I https://example.com", check: .ran(#"curl\b.*(\s-[a-zA-Z]*I|--head)"#)),
            Mission("Download https://example.com into page.html", hint: "curl -o FILE URL.", solution: "curl -s -o page.html https://example.com", check: .contains("page.html", "Example Domain")),
            Mission("Check whether wget is installed", hint: "which, type or command -v.", solution: "which wget", check: .ran(#"(which|type|command\s+-v)\s+wget"#)),
        ]
    )

    static let remote = Lesson(
        id: "remote",
        title: "ssh, scp & rsync",
        commands: ["ssh", "ssh-keygen", "scp", "rsync"],
        topics: ["ssh", "SSH keys", "scp", "rsync"],
        summary: "Log into remote machines, copy files to and from them, and keep folders in sync. You can practice scp and rsync locally because both accept plain paths.",
        sections: [
            S("ssh: a shell on another machine", """
            `ssh user@host` opens an encrypted shell on a remote machine. `-p 2222` picks a non-standard port and `-i key` picks a key. Everything you type runs over there until you `exit`.

            Shortcuts for hosts you use often go in `~/.ssh/config`.
            """, example: Example("ssh deploy@203.0.113.10")),
            S("Keys instead of passwords", """
            `ssh-keygen -t ed25519` creates a key pair. The **private key** never leaves your machine. The **public key** (`.pub`) goes into `~/.ssh/authorized_keys` on the server, and `ssh-copy-id user@host` does that for you.
            """, example: Example("ssh-keygen -t ed25519 -f ./demo_key -N \"\"")),
            S("scp: copy over ssh", """
            `scp file user@host:/path/` uploads and `scp user@host:/path/file .` downloads. Add `-r` for folders. Plain local paths work too, so you can practice right here.
            """),
            S("rsync: copy only what changed", """
            `rsync -av src/ dest/` copies src into dest and on later runs only sends what changed. `-a` keeps permissions and timestamps, `-v` lists files, `-n` does a dry run, `--delete` removes files that are gone from src, and `--exclude` skips paths.

            **Trailing slashes matter:** `src/` copies the _contents_ of src, while `src` copies the folder itself.
            """, example: Example("rsync -av --exclude node_modules project/ mirror/")),
        ],
        reference: [
            O("ssh USER@HOST", "Open a remote shell"),
            O("ssh -p PORT -i KEY", "Custom port and key"),
            O("ssh-keygen -t ed25519", "Create a key pair"),
            O("ssh-copy-id USER@HOST", "Install your public key on a server"),
            O("scp FILE HOST:PATH", "Upload a file"),
            O("scp -r DIR HOST:PATH", "Upload a folder"),
            O("rsync -av SRC/ DST/", "Sync SRC's contents into DST"),
            O("rsync -n", "Dry run: show what would change"),
            O("rsync --delete", "Delete files missing from SRC"),
            O("rsync --exclude PAT", "Skip matching paths"),
        ],
        diagram: Diagram(
            "An SSH session with key authentication",
            caption: "Your ssh client proves who you are with the private key, and the server checks it against authorized_keys. After that, everything you type runs in a shell on the server, inside an encrypted tunnel.",
            nodes: [
                N("you", "You", icon: "person.fill", .actor, at: 0, 0),
                N("ssh", "ssh client", icon: "lock.shield", .process, at: 1, 0, detail: "ssh deploy@server"),
                N("priv", "id_ed25519", icon: "key", .file, at: 1, 1, detail: "private, stays here"),
                N("sshd", "sshd", icon: "server.rack", .process, at: 3, 0, detail: "listens on :22"),
                N("auth", "authorized_keys", icon: "key.viewfinder", .file, at: 3, 1, detail: "your .pub key"),
                N("rshell", "bash on server", icon: "terminal", .shell, at: 4, 0, detail: "runs your commands"),
            ],
            groups: [G("Your Mac", ["you", "ssh", "priv"]), G("Server", ["sshd", "auth", "rshell"])],
            edges: [
                E("you", "ssh"),
                E("ssh", "sshd", "encrypted tunnel, port 22"),
                E("priv", "ssh", "signs", dashed: true),
                E("auth", "sshd", "verifies", dashed: true),
                E("sshd", "rshell", "login"),
            ]
        ),
        seed: Seed(
            directories: ["backup", "project/node_modules/left-pad"],
            files: [
                F("notes.txt", "deploy at 5pm\n"),
                F("project/index.js", "console.log('hello')\n"),
                F("project/package.json", "{ \"name\": \"demo\" }\n"),
                F("project/node_modules/left-pad/index.js", "module.exports = s => s\n"),
            ]
        ),
        missions: [
            Mission("Print your ssh client's version", hint: "Capital V.", solution: "ssh -V", check: .ran(#"ssh\s+-V"#)),
            Mission("Create a key pair named demo_key in this folder, with no passphrase", hint: "ssh-keygen with -t ed25519, -f ./demo_key and -N \"\".", solution: "ssh-keygen -t ed25519 -f ./demo_key -N \"\"", check: .all([.exists("demo_key", .file), .exists("demo_key.pub", .file)])),
            Mission("Copy notes.txt into backup/ using scp", hint: "scp works with local paths, just like cp.", solution: "scp notes.txt backup/", check: .all([.ranOK(#"^\s*scp\b"#), .exists("backup/notes.txt", .file)])),
            Mission("Mirror project/ into mirror/ with rsync, skipping node_modules", hint: "rsync -av --exclude node_modules SRC/ DST/. Mind the trailing slashes.", solution: "rsync -av --exclude node_modules project/ mirror/", check: .all([.exists("mirror/index.js", .file), .missing("mirror/node_modules")])),
        ]
    )

    // MARK: - File Compression

    static let compression = Category(
        id: "compression", title: "File Compression", icon: "archivebox",
        blurb: "Bundle and compress folders, peek inside archives, and extract them.",
        lessons: [archives]
    )

    static let archives = Lesson(
        id: "archives",
        title: "zip, unzip & tar",
        commands: ["zip", "unzip", "tar"],
        topics: ["zip", "unzip", "tar", "gzip"],
        summary: "zip is what everyone can open. tar.gz is the standard on servers. Learn both directions: create, list, extract.",
        sections: [
            S("zip and unzip", """
            `zip -r site.zip site` compresses a folder (`-r` goes into subfolders). `unzip -l site.zip` lists the contents without extracting, and `unzip site.zip -d somewhere/` extracts into a folder.
            """, example: Example("zip -r site.zip site")),
            S("tar: bundle, then compress", """
            tar first bundles many files into one, and `-z` then compresses the bundle with gzip. The flags read like a sentence: **c**reate, e**x**tract or lis**t**, **z** for gzip, **v** for verbose, and **f** for the archive file name, which must come right after `f`.
            """, example: Example("tar -czvf logs.tar.gz logs")),
            S("Listing and extracting", """
            `tar -tzf logs.tar.gz` lists what's inside. `tar -xzf logs.tar.gz` extracts into the current folder, and `-C restore/` extracts somewhere else (the folder must exist).

            Always list an archive from someone else before extracting it, so you know what it's about to write.
            """, example: Example("mkdir restore && tar -xzf logs.tar.gz -C restore")),
        ],
        reference: [
            O("zip -r OUT.zip DIR", "Zip a folder"),
            O("unzip -l FILE.zip", "List contents"),
            O("unzip FILE.zip -d DIR", "Extract into DIR"),
            O("tar -czf OUT.tar.gz DIR", "Create a gzipped tarball"),
            O("tar -tzf FILE.tar.gz", "List contents"),
            O("tar -xzf FILE.tar.gz", "Extract here"),
            O("tar -xzf F -C DIR", "Extract into DIR"),
            O("gzip / gunzip FILE", "Compress / decompress one file"),
        ],
        diagram: Diagram(
            "Inside tar -czf",
            caption: "tar bundles the files and folders into one stream, gzip compresses that stream, and the result is written to the archive. tar -xzf runs the same steps in reverse.",
            nodes: [
                N("logs", "logs/", icon: "folder", .file, at: 0, 0, detail: "many files"),
                N("tar", "tar -c", icon: "shippingbox", .process, at: 1, 0, detail: "bundle"),
                N("gzip", "-z (gzip)", icon: "arrow.down.right.and.arrow.up.left", .process, at: 2, 0, detail: "compress"),
                N("archive", "logs.tar.gz", icon: "archivebox", .file, at: 3, 0, detail: "-f names it"),
                N("restore", "restore/logs/", icon: "folder.badge.plus", .file, at: 3, 1, detail: "tar -xzf … -C restore"),
            ],
            edges: [
                E("logs", "tar", "files"),
                E("tar", "gzip", "one stream"),
                E("gzip", "archive", "write"),
                E("archive", "restore", "extract", dashed: true),
            ]
        ),
        seed: Seed(files: [
            F("site/index.html", "<h1>Home</h1>\n"),
            F("site/about.html", "<h1>About</h1>\n"),
            F("site/css/main.css", "body { font-family: sans-serif }\n"),
            F("logs/app.log", SeedData.serverLog),
            F("logs/worker.log", "worker started\nworker finished\n"),
        ]),
        missions: [
            Mission("Zip the site folder into site.zip", hint: "zip needs -r for folders.", solution: "zip -r site.zip site", check: .exists("site.zip", .file)),
            Mission("List what's inside site.zip without extracting it", hint: "unzip has a list option.", solution: "unzip -l site.zip", check: .ranOK(#"unzip\s+-l|zipinfo"#)),
            Mission("Create a gzipped tarball logs.tar.gz from logs/", hint: "c for create, z for gzip, f for file.", solution: "tar -czf logs.tar.gz logs", check: .all([.exists("logs.tar.gz", .file), .ranOK(#"tar\s+-?[a-zA-Z]*c"#)])),
            Mission("Extract logs.tar.gz into a new restore/ folder", hint: "mkdir restore, then tar -xzf with -C.", solution: "mkdir restore\ntar -xzf logs.tar.gz -C restore", check: .any([.exists("restore/logs/app.log", .file), .exists("restore/app.log", .file)])),
        ]
    )
}
