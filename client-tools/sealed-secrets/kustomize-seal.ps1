param (
    [string]$BaseDir = $(Read-Host "Enter the directory containing Kustomize manifests"),
    [string]$OutputDir = "", # Will default to sealed-secrets below
    [string]$CertPath = $(Read-Host "Enter path to public cert for offline sealing (leave blank to use default location: .\sealed-secrets\public-cert.pem)")
)

# Static variables
$sealedSecretsDir = ".sealed-secrets"

if ([string]::IsNullOrWhiteSpace($outputDir)) {
    $outputDir = "$baseDir\sealed-secrets"
}
if ([string]::IsNullOrWhiteSpace($certPath)) {
    $certPath = "$sealedSecretsDir\public-cert.pem"
}

# Ensure output directory exists
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$kustomizationYamlPath = "$BaseDir\kustomization.yaml"
$kustomizationBackupPath = "$kustomizationYamlPath.bak"
# Make a backup of kustomization.yaml
Copy-Item -Path $kustomizationYamlPath -Destination $kustomizationBackupPath -Force
# Get content of kustomization.yaml
$kustomizationFile = Get-Content $kustomizationYamlPath -Raw
# Re-enable secrets environment files
$kustomizationFile = $kustomizationFile -replace "# env: secrets", "env: secrets"
# Write to disk
Set-Content -Path $kustomizationYamlPath -Value $kustomizationFile

# Get all YAML from kustomize
$allYamls = kubectl kustomize $baseDir | Out-String

# Split into documents (by '---')
$yamlDocs = $allYamls -split "(?m)^---\s*$"

foreach ($doc in $yamlDocs) {
    if ($doc -match "kind:\s*Secret") {        
        # Go through lines and find the name
        foreach ($line in ($doc -split "`n")) {
            if ($line -match '^\s*name:\s*(.+?)\s*$') {
                $secretName = $Matches[1]
                # Get the last generated part from the name
                $secretName -match '-[^-]+$'
                $suffix = $Matches[0]
                # Remove it from the secretName
                $secretName = $secretName -replace $suffix, ''
                break
            }
        }
        # Remove suffix out of the temporary file used to seal the secret
        $doc = $doc -replace $suffix, ''  
        
        # Write the doc to a temp file
        $tempSecretFile = "$outputDir\temp-secret.yaml"
        $doc | Out-File -Encoding utf8 $tempSecretFile

        $sealedSecretFile = "$outputDir\sealed-$secretName.yaml"
        if (![string]::IsNullOrWhiteSpace($certPath)) {
            kubeseal --scope cluster-wide --format yaml --cert $certPath -f $tempSecretFile | Out-File -FilePath $sealedSecretFile -Encoding utf8
        } else {
            kubeseal --scope cluster-wide --format yaml -f $tempSecretFile | Out-File -FilePath $sealedSecretFile -Encoding utf8
        }
        Remove-Item $tempSecretFile
    }
}

# Recover original kustomization.yaml
Copy-Item -Path $kustomizationBackupPath -Destination $kustomizationYamlPath -Force
# Remove backup file
Remove-Item $kustomizationBackupPath

Write-Host "SealedSecrets created; update kustomization.yaml manually."
