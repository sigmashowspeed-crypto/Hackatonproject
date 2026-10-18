$ErrorActionPreference = 'Stop'
$applicationDirectory = $PSScriptRoot
$siteUrl = 'http://localhost:3002'
$env:PORT = '3002'
$env:HOSTNAME = '0.0.0.0'
$env:DATABASE_URL = 'file:' + (Join-Path $applicationDirectory 'data\fikr.db')
$running = $false
try { $response = Invoke-WebRequest ($siteUrl + '/api/bootstrap') -UseBasicParsing -TimeoutSec 2; $running = $response.StatusCode -eq 200 } catch {}
if (-not $running) {
  $server = Start-Process -FilePath (Join-Path $applicationDirectory 'node.exe') -ArgumentList @('server.js') -WorkingDirectory $applicationDirectory -WindowStyle Hidden -RedirectStandardOutput (Join-Path $applicationDirectory 'data\server.log') -RedirectStandardError (Join-Path $applicationDirectory 'data\server-error.log') -PassThru
  $server.Id | Set-Content (Join-Path $applicationDirectory 'data\server.pid')
  for ($attempt = 0; $attempt -lt 40; $attempt++) {
    Start-Sleep -Milliseconds 250
    try { $response = Invoke-WebRequest ($siteUrl + '/api/bootstrap') -UseBasicParsing -TimeoutSec 2; if ($response.StatusCode -eq 200) { $running = $true; break } } catch {}
  }
}
if ($running) { Start-Process $siteUrl } else { Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('The site could not start. Please check app/data/server-error.log.', 'FIKR') | Out-Null }
