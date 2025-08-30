# --- Quiet mode (no popups / no output) ---
$ErrorActionPreference      = 'SilentlyContinue'
$VerbosePreference          = 'SilentlyContinue'
$InformationPreference      = 'SilentlyContinue'
$WarningPreference          = 'SilentlyContinue'
$ProgressPreference         = 'SilentlyContinue'

# --- Inputs / config ---
$JsonFile         = "D:\vmconfig\VMConfig.json"
$Config           = Get-Content -Path $JsonFile | ConvertFrom-Json

# Non-interactive credentials (no popup)
$password         = "Nope" | ConvertTo-SecureString -AsPlainText -Force
$credentials      = New-Object System.Management.Automation.PSCredential -ArgumentList "username", $password

$LocalBannerPath  = "P:\NIWC-A\Enable Secret Banner\Banner.cmd"
$RemoteFolder     = "C:\Temp\SecretBanner"
# The remote file will include the VM name to make it unique
# Note: We'll compute the exact remote file path per-VM inside the loop.

# --- Process each VM quietly ---
foreach ($vm in $Config.VMs.PSObject.Properties.Name) {
    try {
        # Build FQDN consistently from config
        $fqdn = "{0}.{1}" -f $Config.VMs.$vm.hostname, $Config.Top.Domain
        $RemoteFile = Join-Path $RemoteFolder ("Secret Banner for {0}.cmd" -f $vm)

        # Open session (no prompt) and create remote folder
        $session = New-PSSession -ComputerName $fqdn -Credential $credentials
        if (-not $session) { continue }

        Invoke-Command -Session $session -ScriptBlock {
            param($Folder)
            New-Item -ItemType Directory -Path $Folder -Force | Out-Null
        } -ArgumentList $RemoteFolder | Out-Null

        # Copy banner to remote with unique name
        Copy-Item -Path $LocalBannerPath -Destination $RemoteFile -ToSession $session | Out-Null

        # Execute the banner on the remote machine
        Invoke-Command -Session $session -ScriptBlock {
            param($FilePath)
            # Start then wait to finish; fully silent
            Start-Process -FilePath $FilePath -WindowStyle Hidden -Wait
        } -ArgumentList $RemoteFile | Out-Null
    }
    catch {
        # Silent by design
    }
    finally {
        if ($session) { Remove-PSSession -Session $session }
    }
}

# Do NOT run the local banner (removed: & $LocalBannerPath)
