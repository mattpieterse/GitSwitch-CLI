# Copyright (C) 2025  Matthew Pieterse
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.  See LICENSE for more details.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Account
)

# -- Functions

function Test-GitInstallation {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    # Check if git is installed
    try {
        # Validate by running the git command
        $null = git --version
        return $true
    }
    catch {
        Write-Error("Git is not installed or not in PATH: $_")
        return $false
    }
}

function Show-CurrentConfig {
    [CmdletBinding()]
    param()

    try {
        Write-Host("`nCurrent Git Configuration:") -ForegroundColor Green
        Write-Host("------------------------") -ForegroundColor Green
        
        $configKeys = @('user.name', 'user.email', 'user.signingkey')
        foreach ($key in $configKeys) {
            $value = git config --global $key
            Write-Host("$key`: $value")
        }

        Write-Host("`nTesting SSH connection for $Account profile...") -ForegroundColor Yellow
        $sshCommand = "ssh -T git@github.com-$Account 2>&1"
        $sshOutput = Invoke-Expression($sshCommand)

        # GitHub's success message contains this specific text
        if ($sshOutput -match "successfully authenticated") {
            Write-Host("SSH connection successful!") -ForegroundColor Green
            return $true
        } else {
            throw ("SSH authentication failed: $sshOutput")
        }
    }
    catch {
        Write-Error("Failed to display configuration: $_")
        return $false
    }
}

function Get-GitConfig {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    # Try parsing the configuration file
    try {
        # Load the configuration file
        $configPath = Join-Path -Path $PSScriptRoot -ChildPath 'config.json'
        if (-not (Test-Path($configPath))) {
            throw "Configuration file not found: $configPath"
        }

        $configFile = Get-Content $configPath -Raw | ConvertFrom-Json

        # Convert JSON to HashTable
        $Script:GitConfigs = @{}
        foreach ($entity in $configFile.accounts.PSObject.Properties) {
            $config = @{}

            # Validate the schema of the configuration file
            foreach ($field in @('name', 'email', 'signingKey', 'sshCommand')) {
                if (-not ($entity.Value.$field)) {
                    throw "The required field '$($entity.Name)/$field' is missing from the configuration file."
                }

                $config[$field] = $entity.Value.$field
            }

            # Add the configuration to the global variables
            $Script:GitConfigs[$entity.Name] = $config
        }

        # Validate parameters against the configuration
        if (-not ($Script:GitConfigs.ContainsKey($Account))) {
            throw "The account '$Account' does not exist in the configuration file."
        }

        return $Script:GitConfigs
    }
    catch {
        Write-Error("Failed to initialize configuration: $_")
        return $null
    }
}

function Set-GitConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Account
    )
    
    try {
        $config = $Script:GitConfigs[$Account]
        $gitConfig = @(
            @{ Key = 'user.name'; Value = $config.name }
            @{ Key = 'user.email'; Value = $config.email }
            @{ Key = 'user.signingkey'; Value = $config.signingKey }
            @{ Key = 'core.sshCommand'; Value = $config.sshCommand }
            @{ Key = 'commit.gpgsign'; Value = 'true' }
            @{ Key = 'gpg.format'; Value = 'ssh' }
        )

        foreach ($cfg in $gitConfig) {
            git config --global $cfg.Key $cfg.Value

            # Check if the command was successful
            if ($LASTEXITCODE -ne 0) {
                throw ("Git configuration failed: $($cfg.Key)")
            }
        }
    }
    catch {
        Write-Error("Git configuration failed: $_")
        return $false
    }

    return $true
}

# -- Execution

try {
    $config = Get-GitConfig
    if (-not $config) {
        throw ("Configuration initialization failed")
    }

    if (-not (Test-GitInstallation)) {
        throw ("Git installation check failed")
    }

    if (-not (Set-GitConfig -Account $Account)) {
        throw ("Git configuration failed")
    }

    if (-not (Show-CurrentConfig)) {
        throw ("Failed to verify configuration")
    }
}
catch {
    Write-Error("Script execution failed: $_")
    exit 1
}