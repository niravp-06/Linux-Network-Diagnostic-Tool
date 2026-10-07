# NetDiag — Linux Network Diagnostic Tool

NetDiag is a Bash-based command-line tool for performing basic network diagnostics on Linux systems.

It combines common Linux networking utilities into a single tool to quickly check network interface status, IP address, default gateway, DNS functionality, Internet connectivity, latency, and local TCP ports.

## Features

- Detects the active network interface
- Displays IPv4 address and interface state
- Detects and tests the default gateway
- Checks DNS configuration and resolution
- Tests Internet connectivity
- Measures network latency
- Checks local TCP ports:
  - SSH (22)
  - HTTP (80)
  - HTTPS (443)
- Displays an overall network health status
- Saves diagnostic results to a log file
- Provides a help option
- Checks required Linux commands before execution

## Technologies Used

- Linux / Ubuntu
- Bash Shell Scripting
- `ip`
- `ping`
- `ss`
- `resolvectl`
- `dig`
- `grep`
- `awk`
- `sed`
- `cut`

## Project Structure

```text
netdiag/
├── netdiag.sh
├── README.md
└── logs/
    └── netdiag.log
```

## Requirements

The tool is designed for Linux systems and requires the following commands:

```text
ip
ping
ss
resolvectl
dig
awk
grep
sed
cut
```

## Installation

Clone the repository or download the project files, then move into the project directory:

```bash
cd netdiag
```

Make the script executable:

```bash
chmod +x netdiag.sh
```

## Usage

Run the diagnostic tool:

```bash
./netdiag.sh
```

Display the help information:

```bash
./netdiag.sh --help
```

or:

```bash
./netdiag.sh -h
```

## Example Output

```text
========================================
       LINUX NETWORK DIAGNOSTIC
========================================

[1] Network Interface
    Interface : enp0s3
    State     : UP
    IP        : 192.168.1.10

[2] Default Gateway
    Gateway : 192.168.1.1
    Status  : REACHABLE

[3] DNS
    DNS Server : 192.168.1.1
    Status     : WORKING

[4] Internet Connectivity
    Target : 8.8.8.8
    Status : ONLINE
    Latency: 24.5 ms

[5] Local Port Check
    SSH (22) : OPEN
    HTTP (80) : CLOSED
    HTTPS (443) : CLOSED

========================================
Overall Status : HEALTHY
========================================
```

## Logging

NetDiag stores a summary of each diagnostic run in:

```text
logs/netdiag.log
```

This allows previous results to be reviewed later.

## How It Works

The tool follows a basic diagnostic workflow:

```text
Network Interface
       ↓
Default Gateway
       ↓
DNS Resolution
       ↓
Internet Connectivity
       ↓
Latency Check
       ↓
Local TCP Ports
       ↓
Overall Network Status
       ↓
Log File
```

## Project Objective

The main objective of NetDiag is to simplify basic Linux network troubleshooting by combining multiple networking commands into one easy-to-use command-line utility.

The project also demonstrates practical knowledge of:

- Linux networking
- Bash scripting
- Command pipelines
- Conditional statements
- Functions and variables
- Text processing
- Network troubleshooting
- Logging

## Limitations

NetDiag is intended for basic network diagnostics. It does not perform advanced packet analysis, remote port scanning, or detailed network performance monitoring.

## Future Improvements

Possible future enhancements include:

- IPv6 support
- Configurable Internet test targets
- More command-line options
- Detailed DNS diagnostics
- Remote port testing
- JSON output
- Colored terminal output
- More detailed log analysis

## Author

**Nirav Panchal**  
Bachelor of Engineering — Information Technology — Semester 7 
Shree Swaminarayan Institute of Technology (SSIT)  
Gujarat Technological University (GTU)