$ErrorActionPreference = "Stop"

param(
    [string] $ComposeFile = "docker-compose.yml",
    [switch] $Apply
)

$root = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")

function Invoke-DrillStep {
    param(
        [string] $Name,
        [scriptblock] $Command
    )
    Write-Host "`n== $Name ==" -ForegroundColor Cyan
    & $Command
}

if (-not $Apply) {
    Write-Host "Dry run only. Re-run with -Apply to stop/restart services." -ForegroundColor Yellow
}

Invoke-DrillStep "Preflight health targets" {
    Write-Host "Check these endpoints before and after each drill:"
    Write-Host "- Spring:        /actuator/health"
    Write-Host "- Scouting AI:   /health"
    Write-Host "- Academy AI:    /health"
    Write-Host "- Chatbot/N8N:   service-specific health or workflow smoke checks"
}

$drills = @(
    @{ Name = "scouting-ai-service"; Expected = "Spring scouting endpoints return controlled unavailable/fallback response." },
    @{ Name = "academy-ranking-ai-service"; Expected = "Spring academy rankings use weighted fallback." },
    @{ Name = "n8n"; Expected = "Chatbot returns service-unavailable/fallback AI response." },
    @{ Name = "redis"; Expected = "Cache-backed flows degrade without data loss." }
)

foreach ($drill in $drills) {
    Invoke-DrillStep "Drill: $($drill.Name)" {
        Write-Host "Expected: $($drill.Expected)"
        if ($Apply) {
            Push-Location $root
            try {
                docker compose -f $ComposeFile stop $drill.Name
                Start-Sleep -Seconds 20
                docker compose -f $ComposeFile start $drill.Name
            } finally {
                Pop-Location
            }
        } else {
            Write-Host "Would run: docker compose -f $ComposeFile stop $($drill.Name)"
            Write-Host "Would wait 20 seconds, verify behavior, then restart the service."
        }
    }
}

Write-Host "`nRecord results in production-audit/final-production-readiness-report.md before production sign-off." -ForegroundColor Green

