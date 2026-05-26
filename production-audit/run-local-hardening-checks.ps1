$ErrorActionPreference = "Stop"

$root = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
$pythonDeps = Join-Path $root "production-audit\python-test-deps"
$env:PYTHONDONTWRITEBYTECODE = "1"

function Invoke-Step {
    param(
        [string] $Name,
        [scriptblock] $Command
    )
    Write-Host "`n== $Name ==" -ForegroundColor Cyan
    & $Command
}

Invoke-Step "Spring backend tests" {
    Push-Location (Join-Path $root "sports_management_project")
    try {
        mvn -q clean test -DskipITs
        if (Test-Path -LiteralPath "target\classes\Files\Data\data.json") {
            throw "Demo seed data was packaged into target/classes."
        }
    } finally {
        Pop-Location
    }
}

Invoke-Step "Scouting AI tests" {
    Push-Location (Join-Path $root "scouting-ai-service")
    try {
        $env:PYTHONPATH = $pythonDeps
        python -m pytest tests -v -p no:cacheprovider
    } finally {
        Pop-Location
    }
}

Invoke-Step "Academy Ranking AI tests" {
    Push-Location (Join-Path $root "academy-ranking-ai-service")
    try {
        $env:PYTHONPATH = $pythonDeps
        python -m pytest tests -v -p no:cacheprovider
    } finally {
        Pop-Location
    }
}

Invoke-Step "N8N orchestration tests" {
    Push-Location (Join-Path $root "n8n-service-orchestration")
    try {
        $env:PYTHONPATH = $pythonDeps
        python -m pytest tests -v -p no:cacheprovider
    } finally {
        Pop-Location
    }
}

Invoke-Step "Django chatbot smoke tests" {
    Push-Location (Join-Path $root "chatbot\chatbot")
    try {
        $env:PYTHONPATH = $pythonDeps
        python -m pytest apps\chat\tests -v -p no:cacheprovider
    } finally {
        Pop-Location
    }
}

Invoke-Step "Flutter tests" {
    Push-Location (Join-Path $root "sports-app")
    try {
        flutter test
    } finally {
        Pop-Location
    }
}

Invoke-Step "Python Bandit SAST" {
    Push-Location $root
    try {
        $env:PYTHONPATH = $pythonDeps
        python -m bandit -r scouting-ai-service\app scouting-ai-service\adminplatform academy-ranking-ai-service\app n8n-service-orchestration\service-registry n8n-service-orchestration\webhooks chatbot\chatbot\apps -x chatbot\chatbot\apps\chat\tests_comprehensive.py -q
    } finally {
        Pop-Location
    }
}

Invoke-Step "Python dependency audit" {
    Push-Location $root
    try {
        $env:PYTHONPATH = $pythonDeps
        $cache = Join-Path $root "production-audit\pip-audit-cache"
        New-Item -ItemType Directory -Force -Path $cache | Out-Null
        $requirements = @(
            "scouting-ai-service\requirements.txt",
            "academy-ranking-ai-service\requirements.txt",
            "n8n-service-orchestration\requirements.txt",
            "chatbot\chatbot\requirements.txt"
        )
        foreach ($req in $requirements) {
            python -m pip_audit --cache-dir $cache --no-deps -r $req
        }
    } finally {
        Pop-Location
    }
}

Write-Host "`nAll local hardening checks completed." -ForegroundColor Green
