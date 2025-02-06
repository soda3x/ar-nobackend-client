param (
  [string]$ConfigFile,
  [string]$AddonsDir,
  [string]$OutputDir,
  [switch]$Help
)

if ($Help) {
  Write-Output "Arma Reforger No Backend Packager"
  Write-Output "Usage: arma-reforger-nbp.ps1 -ConfigFile <path> -AddonsDir <path> -OutputDir <path>"
  Write-Output "Parameters:"
  Write-Output "  -ConfigFile  Path to the JSON configuration file."
  Write-Output "  -AddonsDir   Path to the addons directory."
  Write-Output "  -OutputDir   Path to where the packaged client files should be created."
  Write-Output "  -Help        Show this help message."
  exit 0
}

if (-Not (Test-Path $ConfigFile)) {
  Write-Error "Config file not found: $ConfigFile"
  exit 1
}

if (-Not (Test-Path $AddonsDir -PathType Container)) {
  Write-Error "Addons directory not found: $AddonsDir"
  exit 1
}

# Create the output directory if it doesn't exist
if (-not (Test-Path $OutputDir)) {
  New-Item -ItemType Directory -Path $OutputDir
}

$OutputAddons = "$($OutputDir)\\addons"

if (-not (Test-Path $OutputAddons)) {
  New-Item -ItemType Directory -Path $OutputAddons
}

$Addons = Get-ChildItem -Path $AddonsDir -Directory

$Config = Get-Content $ConfigFile | ConvertFrom-Json
Write-Output "Loaded configuration from $ConfigFile"
$RequiredMods = $Config.game.mods

foreach ($Mod in $RequiredMods) {
  $modId = $($Mod.ModId)
  $modName = $($Mod.Name)
  Write-Output "Server requires the mod '$modName', looking for it in the addons directory..."

  $MatchingAddons = $Addons | Where-Object { $_.Name -like "*$modId*" }

  if ($MatchingAddons) {
    $MatchingAddons | ForEach-Object {
      Write-Output "Found $($_.Name) in the addons directory, this will be packaged"
      Copy-Item -Path $_.FullName -Destination $OutputAddons -Recurse -Force
    }
  }
  else {
    Write-Output "Could not find $modName in the addons directory, it will not be included..."
  }
}

$BatchFilePath = "$OutputDir\\start_reforger.bat"

$ClientAddress = $Config.publicAddress
$ClientPort = $Config.publicPort
$ClientMods = ""

foreach ($mod in $RequiredMods) {
  if ($ClientMods) {
    $ClientMods += ","
  }
  $ClientMods += $mod.ModId
}

$BatchContent = @"
start "" "C:\Program Files (x86)\Steam\steam.exe" -applaunch 1874880 -client $($ClientAddress):$($ClientPort) -addonsDir "./addons" -addons $ClientMods
"@

# Create the batch file and write the content to it
$BatchContent | Out-File -FilePath $BatchFilePath -Encoding ASCII

$ZipName = "$OutputDir\play_reforger_on_$($Config.game.name).zip"


Compress-Archive -Path "$OutputDir\\*" -DestinationPath $ZipName -Force

Write-Output "Packaging completed. Distribute '$ZipName' with your players."
