# Author: Sviatoslav Oleksiienko
# Date: 01/13/2025
# 

# functions
param([string]$dataBasePath=".\EquipmentDataBase.csv")
function Get-MonitorsStats(){
    # Serial number, manufacturing Date and Week
    $monitors = Get-WmiObject -Class WmiMonitorID -Namespace "root\wmi" | Where{$_.Active} 
    $monitorData = foreach($monitor in $monitors){
        $manufacturerName = [System.Text.Encoding]::ASCII.GetString($monitor.ManufacturerName) -replace '\0+$'
        $manufactureWeek = $monitor.WeekOfManufacture
        $manufactureYear = $monitor.YearOfManufacture
        $manufactureSerial = [System.Text.Encoding]::ASCII.GetString($monitor.SerialNumberID) -replace '\0+$'

        if ([string]::IsNullOrEmpty($manufactureSerial) -or $manufactureSerial -match '^\s*$' -or $manufactureSerial -eq "0"){
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
$monitorsFound = Get-MonitorsStats

if (Test-Path $dataBasePath){
$monitorsToAdd = @();
$monitorsDatabase = Import-Csv -Path $dataBasePath

foreach ($monitorFound in $monitorsFound){
    foreach ($monitorDataBase in $monitorsDataBase){
        if($monitorDataBase.ManufactureSerial -ne $monitorFound.ManufactureSerial){
            $monitorsToAdd += $monitorFound
        }
    }
}
$monitorsToAdd | Export-CSV -Path $dataBasePath -NoTypeInformation -Append
}
else{
    $monitorsFound | Export-CSV -Path $dataBasePath -NoTypeInformation
}