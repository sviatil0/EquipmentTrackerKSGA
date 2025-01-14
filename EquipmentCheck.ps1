# Author: Sviatoslav Oleksiienko
# Date: 01/13/2025
# 

# functions
param([string]$dataBasePath=".\EquipmentDataBase.csv")
function Get-MonitorsStats{
    # Serial number, manufacturing Date and Week
    $monitors = Get-WmiObject -Class WmiMonitorID -Namespace "root\wmi" | Where{$_.Active} 
    $monitorData = foreach($monitor in $monitors){
        $manufacturerName = [System.Text.Encoding]::ASCII.GetString($monitor.ManufacturerName) -replace '\0+$'
        $manufactureWeek = $monitor.WeekOfManufacture
        $manufactureYear = $monitor.YearOfManufacture
        $manufactureSerial = [System.Text.Encoding]::ASCII.GetString($monitor.SerialNumberID) -replace '\0+$'

        if ([string]::IsNullOrEmpty($manufactureSerial) -or $manufactureSerial -match '^\s*$' -or $manufactureSerial -eq "0"){
            "" 

            $manufactureSerial = Read-Host "Failed to find a monitor's (manufactured in $manufactureYear, week $manufactureWeek by $manufacturerName manufacturer) serial number.`nEnter Serial Number (check the back side of the monitor)"
        }

        [PSCustomObject]@{
            ComputerName = $env:COMPUTERNAME
            ManufacturerName = $manufacturerName
            ManufactureYear = $manufactureYear
            ManufactureWeek = $manufactureWeek
            ManufactureSerial = $manufactureSerial
        } 
    }
    return $monitorData
}

# Main Script
$monitors = Get-MonitorsStats
$monitors | Export-CSV -Path $dataBasePath -NoTypeInformation -Append
# echo $monitors

# Appends and then import again to check if the same 
# if (Test-Path $dataBasePath) {
#     $ImportedDataBase =  Import-CSV -Path $dataBasePath
#     $UniqueDataBase = $monitors
# }
# else {
#     $UniqueDataBase = $monitors
# }
