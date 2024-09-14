# This script requires PowerShell version 7 and the Az.Accounts and Az.Storage modules
#requires -Version 7 -Modules Az.Accounts, Az.Storage

# Define parameters for the script
param(
    # Path to the configuration file, default is ".\Config.json"
    [string]$configFilePath = ".\Config.json"
    ,
    # Array of scripts to run, default includes ".\UploadGatewayLogs.ps1"
    [array]$scriptsToRun = @(
        ".\UploadGatewayLogs.ps1"
    )
)

# Set error action preference to stop on any error
$ErrorActionPreference = "Stop"

# Get the directory path of the current script
$currentPath = (Split-Path $MyInvocation.MyCommand.Definition -Parent)

# Set the current working directory to the script's directory
Set-Location $currentPath

# Import the Utils module from the current directory
Import-Module "$currentPath\Utils.psm1" -Force

# Display the current working directory
Write-Host "Current Path: $currentPath"

# Display the path to the configuration file
Write-Host "Config Path: $configFilePath"

# Check if the configuration file exists
if (Test-Path $configFilePath) {
    # If it exists, load and parse the JSON content
    $config = Get-Content $configFilePath | ConvertFrom-Json

    # Set default values if not present in the config
    if (!$config.OutputPath) {        
        # Add OutputPath property with default value ".\Data" if it doesn't exist
        $config | Add-Member -NotePropertyName "OutputPath" -NotePropertyValue ".\\Data" -Force
    }
}
else {
    # If the config file doesn't exist, throw an error
    throw "Cannot find config file '$configFilePath'"
}

try {
    # Iterate through each script in the scriptsToRun array
    foreach ($scriptToRun in $scriptsToRun)
    {        
        try {
            # Display which script is currently running
            Write-Host "Running '$scriptToRun'"

            # Execute the script, passing the config object as a parameter
            & $scriptToRun -config $config
        }
        catch {            
            # If an error occurs while running a script, log it and continue to the next script
            Write-Error "Error on '$scriptToRun' - $($_.Exception.ToString())" -ErrorAction Continue            
        }   
    }
}
catch {
    # If an unhandled exception occurs in the main try block
    $ex = $_.Exception

    # Re-throw the exception
    throw    
}
