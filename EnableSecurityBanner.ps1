# Establish the remote session (your original code was correct here)
$JsonFile = "D:\vmconfig\VMConfig.json"
$Config = Get-Content -Path $JsonFile | ConvertFrom-Json
$password = "Nope" | ConvertTo-SecureString -AsPlainText -Force
$credentails = New-Object System.Management.Automation.PSCredential -ArgumentList "username", $password
$localBannerPath = "P:\NIWC-A\Enable Secret Banner\Banner.cmd"

# Create the Temp directory on the remote machine (fixed the typo)

# Define local and remote paths

# Note: Ensure the variables $config and $vm are defined before this line
foreach ($vm in $Config.VMs.PSObject.Properties.GetEnumerator().Name){
    $fqdn = "$($config.VMs.$vm.hostname).$($config.top.Domain)"
    $RemoteBannerFolder = "C:\temp\SecretBanner\"
    $RemoteBannerPath = "C:\Temp\SecretBanner\Secret Banner for $($vm).cmd"
    try{
        $session = New-PSSession -ComputerName $fqdn -Credential $credentials -ErrorAction SilentlyContinue
        Invoke-Command -Session $session -ScriptBlock {   
        param($LocalBannerPath, $RemoteBannerPath, $RemoteBannerFolder, $session)
        New-Item -ItemType Directory -Path $RemotebannerFolder -Force 
    }-ArgumentList $RemoteBannerPath, $LocalBannerPath, $RemoteBannerFolder

   Copy-Item -Path $LocalBannerPath -Destination $RemoteBannerPath -ToSession $session

        Invoke-Command -Session $session -ScriptBlock {   
        param($LocalBannerPath, $RemoteBannerPath, $RemoteBannerFolder, $session)
        Start-Process -FilePath "C:\Temp\*.cmd" 
    }-ArgumentList $RemoteBannerPath

    }Catch{}
 } & $localBannerPath