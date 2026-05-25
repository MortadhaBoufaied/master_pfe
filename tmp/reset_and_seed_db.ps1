$projectRoot = "D:\Nouveau dossier\sports_management_project"
$seedFile = "D:\Nouveau dossier\sports_management_project\src\main\resources\Files\Data\data.json"

Set-Location -LiteralPath $projectRoot

$env:APP_SEED_FULL_JSON = "true"
$env:APP_SEED_FILE = $seedFile
$env:APP_SEED_EXIT_AFTER_RUN = "true"
$env:SPRING_JPA_HIBERNATE_DDL_AUTO = "create"

mvn spring-boot:run
