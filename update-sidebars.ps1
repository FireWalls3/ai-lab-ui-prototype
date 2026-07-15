$pages = @("superadmin-dashboard.html","superadmin-organizations.html","superadmin-billing.html","superadmin-infrastructure.html","superadmin-support.html","superadmin-features.html","superadmin-announcements.html")
foreach ($page in $pages) {
  $content = Get-Content $page -Raw -Encoding UTF8
  if ($content -match 'superadmin-analytics') { Write-Host "$page already done"; continue }
  $analyticsLink = '<a class="nav-link" href="superadmin-analytics.html"><svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 3v18h18"/><path d="M18 17V9"/><path d="M13 17V5"/><path d="M8 17v-3"/></svg><span>Analytics</span></a>'
  $aiModels = '<a class="nav-link" href="superadmin-ai-models.html"><svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M12 2v3m0 14v3M2 12h3m14 0h3"/></svg><span>AI Models</span></a>'
  $auditLink = '<a class="nav-link" href="superadmin-audit-logs.html"><svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6M16 13H8"/></svg><span>Audit Logs</span></a>'
  $content = $content -replace '(<a class="nav-link[^"]*" href="superadmin-infrastructure)', "$analyticsLink`n$aiModels`n`$1"
  $content = $content -replace '(<a class="nav-link[^"]*" href="superadmin-announcements)', "$auditLink`n`$1"
  [System.IO.File]::WriteAllText((Resolve-Path $page).Path, $content, [System.Text.Encoding]::UTF8)
  Write-Host "Updated: $page"
}
