$j = Get-Content -Raw 'ressources/files/Data/data.json' | ConvertFrom-Json
$fields = @(
  'sports','sportStatistics','platformOffers','platformFeatures','academies',
  'academyUserSubscriptionSettings','academyPayments',
  'divisions','users','trainers','parents','players',
  'payments','userSubscriptions','activities',
  'conversations','messages','messageReads','notifications',
  'playerAttributeSnapshots','playerProgressions',
  'playerPerformanceObservations','talentScores',
  'scouters','scouterWatchedPlayers','scoutingReports',
  'academyPerformanceScores'
)
foreach($f in $fields){
  $arr = $j.PSObject.Properties[$f].Value
  $c = 0
  if($arr -is [System.Array]){ $c = $arr.Count } else { $c = 0 }
  Write-Output ($f + ':' + $c)
}
Write-Output ('aiDatasets.playerSnapshots:' + $j.aiDatasets.playerSnapshots.Count)
Write-Output ('aiDatasets.academySnapshots:' + $j.aiDatasets.academySnapshots.Count)
