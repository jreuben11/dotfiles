# fnm (Fast Node Manager) — Nushell integration
# Parses `fnm env` bash output and applies it to the Nu environment

let fnm_out = (^fnm env | lines | parse --regex 'export (?P<key>[^=]+)="(?P<value>[^"]*)"')

let fnm_path_rows = ($fnm_out | where key == "PATH" | get value)
let fnm_bin = if ($fnm_path_rows | is-not-empty) { $fnm_path_rows | first } else { "" }
if ($fnm_bin | is-not-empty) {
    $env.PATH = ($env.PATH | prepend $fnm_bin)
}

$fnm_out
| where key != "PATH"
| reduce -f {} { |row, acc| $acc | insert $row.key $row.value }
| load-env
