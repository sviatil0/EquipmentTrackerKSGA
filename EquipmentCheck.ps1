# Author: Sviatoslav Oleksiienko
# 
#Parameters
param([string]$dataBasePath=".\EquipmentDataBase.csv")

#Import
Add-Type -AssemblyName Microsoft.VisualBasic

# functions
function Get-MonitorsStats(){
    # Serial number, manufacturing Date and Week
    $monitors = Get-WmiObject -Class WmiMonitorID -Namespace "root\wmi" | Where{$_.Active} 
    $monitorData = foreach($monitor in $monitors){
        $manufacturerName = [System.Text.Encoding]::ASCII.GetString($monitor.ManufacturerName) -replace '\0+$'
        $manufactureWeek = $monitor.WeekOfManufacture
        $manufactureYear = $monitor.YearOfManufacture
        $manufactureSerial = [System.Text.Encoding]::ASCII.GetString($monitor.SerialNumberID) -replace '\0+$'

        if ([string]::IsNullOrEmpty($manufactureSerial) -or $manufactureSerial -match '^\s*$' -or $manufactureSerial -eq "0"){
            # Show an input dialog box
        $manufactureSerial = [Microsoft.VisualBasic.Interaction]::InputBox(
            "Failed to find a monitor's (manufactured in $manufactureYear, week $manufactureWeek by $manufacturerName manufacturer) serial number.`nEnter Serial Number (check the back side of the monitor).",
            "Enter Serial Number (write 'skip' to skip this monitor)")
        }
        if ($manufactureSerial -eq "skip"){
            continue 
        }
        [PSCustomObject]@{
            ComputerName = $env:COMPUTERNAME
            ManufacturerName = $manufacturerName
            ManufactureYear = $manufactureYear
            ManufactureWeek = $manufactureWeek
            ManufactureSerial = $manufactureSerial
            Type = "Monitor"
        } 
    }
    return $monitorData
}
function Get-HubsStats(){
# TODO
# https://learn.microsoft.com/en-us/powershell/module/pnpdevice/get-pnpdevice?view=windowsserver2025-ps
# seems that Generic USB Hub is what hubs should be called
}
# Main Script
$monitorsFound = Get-MonitorsStats

if (Test-Path $dataBasePath){
$monitorsToAdd = @();
$monitorsDataBase = Import-Csv -Path $dataBasePath
$dataBaseSerials = $monitorsDataBase.ManufactureSerial
# echo $monitorsDataBase


foreach ($monitorFound in $monitorsFound){
    if($monitorFound.ManufactureSerial -notin $dataBaseSerials){
        $monitorsToAdd += $monitorFound
    }
}
$monitorsToAdd | Export-CSV -Path $dataBasePath -NoTypeInformation -Append
}
else{
    $monitorsFound | Export-CSV -Path $dataBasePath -NoTypeInformation
}