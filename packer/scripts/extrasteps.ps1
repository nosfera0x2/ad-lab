# Set a specific DNS server for 'Ethernet 0 2' adapter
Set-DnsClientServerAddress -InterfaceAlias 'Ethernet Instance 0' -ServerAddresses ('192.168.10.1')
Write-Host "DNS server set to 192.168.10.1 for 'Ethernet Instance 0' adapter."

# Set Security Protocol to TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "Security protocol set to TLS 1.2."

# Install NuGet provider and PowerShellGet module
Write-Host "Installing NuGet provider and PowerShellGet module..."
try {
    Install-PackageProvider -Name Nuget -Force
    Write-Host "NuGet provider installed successfully."
    Install-Module -Name PowerShellGet -Force
    Write-Host "PowerShellGet module installed successfully."
} catch {
    Write-Host "Failed to install NuGet provider or PowerShellGet module. Error: $_"
    # Do not exit, just log the error and continue
}

# Create C:\Setup directory if it does not exist
if (!(Test-Path -Path 'C:\\Setup')) {
    New-Item -Path 'C:\\Setup' -ItemType Directory
    Write-Host 'Created C:\\Setup directory.'
} else {
    Write-Host 'C:\\Setup directory already exists.'
}

# Download the MSI file with detailed logging and retry mechanism
$url = 'http://192.168.254.51/CloudbaseInitSetup_Stable_x64.msi'
$outFile = 'C:\\Setup\\CloudbaseInitSetup_Stable_x64.msi'
$maxRetries = 5
$retryInterval = 30  # Wait time (in seconds) between retries
$success = $false

Write-Host "Attempting to download the MSI file from $url..."

for ($i = 0; $i -lt $maxRetries; $i++) {
    try {
        Write-Host "Download attempt $($i + 1)..."
        if (Test-Path $outFile) {
            Remove-Item $outFile -Force
            Write-Host "Removed existing file at $outFile."
        }
        
        Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
        Write-Host "File downloaded successfully on attempt $($i + 1)."
        $success = $true
        break  # Exit loop if successful
    } catch {
        Write-Host "Download attempt $($i + 1) failed. Error: $_"
        if ($i -lt $maxRetries - 1) {
            Write-Host "Retrying in $retryInterval seconds..."
            Start-Sleep -Seconds $retryInterval
        }
    }
}

if (-not $success) {
    Write-Host "Failed to download the MSI file after $maxRetries attempts, but continuing."
} else {
    Write-Host "Successfully downloaded CloudbaseInitSetup_Stable_x64.msi to C:\\Setup"
}

Write-Host "Network and system configurations are complete."
