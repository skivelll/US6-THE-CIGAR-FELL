param(
    [Parameter(Mandatory = $true)]
    [string]$Action,
    [int]$MaxDepth = 8
)

$depth = 0
if ($env:US6_AGENT_DEPTH) {
    [int]::TryParse($env:US6_AGENT_DEPTH, [ref]$depth) | Out-Null
}
if ($depth -ge $MaxDepth) {
    throw "US6 recursion guard stopped '$Action' at depth $depth (limit $MaxDepth). Inspect the caller instead of retrying."
}
$env:US6_AGENT_DEPTH = [string]($depth + 1)
Write-Host "US6 guard: action='$Action', depth=$($depth + 1)/$MaxDepth"
