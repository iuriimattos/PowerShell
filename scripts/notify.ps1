<#
.SYNOPSIS
    Creates a scheduled task that will display a popup message after a delay.
.DESCRIPTION
    This PowerShell script creates a scheduled task that will display a popup message after a specified delay.
.EXAMPLE
    PS> ./remind-me "Dentist" "15min"
    PS> ./remind-me "Dentist" "2h"
    PS> ./remind-me "Dentist" "1d"
.NOTES
    Author: Refactored by Copilot | Original: Markus Fleschutz
#>

#requires -version 4

param(
    [string]$Message = "",
    [string]$Delay = ""
)

function Parse-Delay {
    param([string]$Input)

    if ($Input -match "^(\d+)(min|h|d)$") {
        $value = [int]$matches[1]
        switch ($matches[2]) {
            "min" { return (Get-Date).AddMinutes($value) }
            "h"   { return (Get-Date).AddHours($value) }
            "d"   { return (Get-Date).AddDays($value) }
        }
    } else {
        throw "Invalid delay format. Use formats like '15min', '2h', or '1d'."
    }
}

try {
    if ($Message -eq "") { $Message = Read-Host "Enter reminder message" }
    if ($Delay -eq "") { $Delay = Read-Host "Enter delay (e.g., 15min, 2h, 1d)" }

    $Time = Parse-Delay -Input $Delay
    $Task = New-ScheduledTaskAction -Execute msg -Argument "* $Message"
    $Trigger = New-ScheduledTaskTrigger -Once -At $Time
    $Random = Get-Random
    Register-ScheduledTask -Action $Task -Trigger $Trigger -TaskName "Reminder_$Random" -Description "Reminder"
    exit 0
} catch {
    Write-Host "⚠️ ERROR: $($_.Exception.Message) (script line $($_.InvocationInfo.ScriptLineNumber))"
    exit 1
}
