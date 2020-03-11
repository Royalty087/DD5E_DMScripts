<#
DM's Helper - d100 roller with dates and cumulative totals. 
#>
##########################
## Variable Declaration ##
##########################
    [string]$DateEntry = $null
    [array]$Dates = $Null
    [Int32]$DiceCount = $Null
    [array]$DiceToRoll =@()
    [Int32]$OutCounter = 0
    [array]$OutputObject =@()
    [string]$OutputPath = "C:\Users\$env:USERNAME\Desktop" ## This line can be edited to save output elsewhere.
    [string]$Reason = $null
    [array]$RollArray =@()
    [array]$Rolls =@()
    [array]$Totals =@()

################
## Get values ##
################
    $DateEntry = Read-Host “Type Start Date in mm-dd-yyyy format”
    $DiceCount = Read-Host "How many rolls would you like to simulate?"
    $Reason = Read-Host "Enter Purpose of this roll - will be appended to filename"
    $DiceToRoll =@(1..$DiceCount)
    [datetime]$Date = get-date $DateEntry | Get-Date -UFormat "%A %m-%d-%Y"
    $FormattedDate = $Date | Get-Date -UFormat "%A %m-%d-%Y"

###################
## Process Rolls ##
###################
    foreach($die in $DiceToRoll) {
        #Roll Dice, add result to array
        $Roll = get-random -Minimum 1 -Maximum 101
        $RollArray += $Roll
    
        #Format, save, and increment date
        $FormattedDate = $Date | Get-Date -UFormat "%A %m-%d-%Y"
        $Dates += $FormattedDate
        $Date = $Date.AddDays(1) | Get-Date -UFormat "%A %m-%d-%Y"

        #do math
        $RollSum = ($RollArray | Measure-Object -sum).sum
        $Totals += $RollSum
        }

    
$outputObject = For($OutCounter = 0; $OutCounter -lt $DiceCount; $OutCounter++)
    {
    [pscustomobject] @{
                       'Count' = $DiceToRoll[$OutCounter]
                       'Date' = $Dates[$OutCounter]
                       'Roll' = $RollArray[$OutCounter]
                       'RuningTotal' = $Totals[$OutCounter]
                       }
    }

$outputobject | Export-csv -Path "$OutputPath\d100_Rolls_$Reason.csv" -NoTypeInformation
