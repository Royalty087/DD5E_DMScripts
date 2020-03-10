<#
DD5E_Mass_Combat_Script.ps1
Published on 3/10/2020
Author - Roy K. DeSimone
#>

<#
Reference - 
        "Dice" are rolled die values without modifiers
        "Rolls" are die values with modifiers included.
        Logically there are two teams - Red and Blue
        Major victories are wins with a margin between 5 and 9 - they're noted but do not change any calculations
        Overwhelming victories are wins with a margin of 10 or more - they increase the winner's victory multiplier
        Victory multiplier -- big wins/losses have a major effect on the game.
            The victory multiplier starts at 1. for each of the following events, it will double your score
                -Crit failures are punished by increasing the winner's victory multiplier
                -Crit successes are rewarded by increasing the winner's victory multiplier
                -Overwhelming victories are rewarded by increasing the winner's victory multiplier
            This means that a winner's score could end up with a x8 multiplier in the event of a crit fail vs a crit success, which would also be an ooverwhelming victory
#>

<#
Instructions
    Run script in powershell
    Enter the number of sides on the dice you want to simulate (enter 20 for d20, 8 for d8, etc.)
    Enter how many dice you'd like to roll (this is for EACH team, not for both)
    Enter the modifiers for each team 
    You will be prompted for a battle name - this will be appended to the end of the file name to help you keep organized.

Files will be automatically output to the windows desktop folder of whichever account is running powershell. 
This can be changed/modified by updating the output path variable in the top section of the script.
#>

#######################
## Declare Variables ##
#######################
    [Int32]$BlueMod - $null
    [int32]$CritCount = 0
    [int32]$DieQuantity = $null
    [int32]$DieRoller = $null
    [int32]$DifferenceCount = 0
    [int32]$DieType = $null
    [int32]$OutputCount = 1
    [Int32]$RedMod = $null
    [string]$OutputPath = "C:\Users\$Env:USERNAME\Desktop\" ## if this gets changed, make sure the path is enclosed in double quotes and ends with a backslash '\'
    [Int32]$Score = $null
    [string]$TitleInfo = $null
    [Int32]$VictoryMultiplier = 1

#######################
## Initialize Arrays ##
#######################
    [array]$BattleIndex =@()
    [array]$BlueDice =@()
    [array]$BlueRolls =@()
    [array]$BlueScore =@()
    [array]$DiceToRoll =@()
    [array]$DifferenceArray =@()
    [array]$CritArray =@()
    [array]$RedDice =@()
    [array]$RedRolls =@()
    [array]$RedScore =@()
    [array]$VictoryArray =@()
    [array]$WinnerArray =@()

###################################
## Set Variables with user input ##
###################################
    [int32]$DieType = Read-Host "Enter number of sides on dice"
    [int32]$DieQuantity = Read-Host "How many dice?"
    [int32]$BlueMod = Read-Host "Enter Blue Modifier"
    [Int32]$RedMod = Read-Host "Enter Red Modifier"
    [string]$TitleInfo = Read-Host "Enter battle name (will be appended to file name)"

#################################################################
## Reinitialize die array with upper limit set to the die type ##
#################################################################
    [array]$BattleIndex =@(1..$DieQuantity)
    [array]$DiceToRoll =@(1..$DieQuantity)

######################################################################
## Roll Dice by piping dice to roll count array into get-random and ##
## retrieving <roll quantity> results with limits set by die type   ##
######################################################################
    $DieRoller = $DieType+1 # the get-random cmdlet does NOT include the value passed in the max switch, so increase it by 1 and save as $DieRoller
    $BlueDice = $DiceToRoll | ForEach-Object {Get-Random -Minimum 1 -Maximum $DieRoller}
    $RedDice = $DiceToRoll | ForEach-Object {Get-Random -Minimum 1 -Maximum $DieRoller}

###############################################################################
## Add Modifiers to non fails by iterating through each roll array           ##
## and adding the corresponding modifier to each only if the roll is not a 1 ##
###############################################################################
    $BlueRolls = ForEach($BlueDie in $BlueDice)
        {
        if($BlueDie -ne 1) {$BlueDie + $BlueMod}
        else{$BlueDie}
        }
    $RedRolls = ForEach($RedDie in $RedDice)
        {
        if($RedDie -ne 1){$RedDie + $RedMod}
        else{$RedDie}
        }

##################################################
## Check arrays for crits and create crit array ##
##################################################
    $CritCount = 0
    do{ #Start Crit Loop
    ## Regular Crits vs Regular Rolls
        if (($BlueDice[$CritCount] -eq 20) -and ($Reddice[$CritCount] -ne 20) -and ($Reddice[$CritCount] -ne 1))
            {
            $CritArray += 'Blue Crit!'
            $VictoryMultiplier = 2
            }
        elseif (($BlueDice[$CritCount] -ne 20) -and ($BlueDice[$CritCount] -ne 1) -and ($Reddice[$CritCount] -eq 20))
            {
            $CritArray += 'Red Crit!'
            $VictoryMultiplier = 2
            }
        elseif (($BlueDice[$CritCount] -eq 20) -and ($Reddice[$CritCount] -eq 20))
            {$CritArray += 'Double Crits!'}
    ## Regular Fails vs Regular Rolls
        elseif (($BlueDice[$CritCount] -eq 1) -and ($Reddice[$CritCount] -ne 1) -and ($Reddice[$CritCount] -ne 20))
            {
            $CritArray += 'Blue Fail!'
            $VictoryMultiplier = 2
            }
        elseif (($BlueDice[$CritCount] -ne 1) -and ($BlueDice[$CritCount] -ne 20) -and ($Reddice[$CritCount] -eq 1))
            {
            $CritArray += 'Red Fail!'
            $VictoryMultiplier = 2
            }
        elseif (($BlueDice[$CritCount] -eq 1) -and ($Reddice[$CritCount] -eq 1))
            {$CritArray += 'Double Fails!'}
    ## Crits vs Fails
        elseif (($BlueDice[$CritCount] -eq 1) -and ($Reddice[$CritCount] -eq 20))
            {
            $CritArray += 'Red Crit vs. Blue Fail!'
            $VictoryMultiplier = 4
            }
        elseif (($BlueDice[$CritCount] -eq 20) -and ($Reddice[$CritCount] -eq 1))
            {
            $CritArray += 'Blue Crit vs. Red Fail!'
            $VictoryMultiplier = 4
            }
    ## No Crits
        else {$CritArray += ''}
    ## Increment Counter
        $CritCount++
    }#End Crit Loop
        until($CritCount -eq $DieQuantity)
        $PostCritMultiplier = $VictoryMultiplier

#############################################################################
## Compare arrays and create Winner, Difference, Victory, and Score Arrays ##
#############################################################################
    $DifferenceCount = 0
    do{#Start Difference Loop
        $Difference = $null 
        if ($BlueRolls[$DifferenceCount] -gt $RedRolls[$DifferenceCount]) 
            
            { #Blue Win Scenarios
            
            $Difference = $BlueRolls[$DifferenceCount] - $RedRolls[$DifferenceCount]
            $DifferenceArray += $Difference
            $WinnerArray += 'Blue'
                if($Difference -ge 5 -and $Difference -lt 10) #Major Blue Victory
                    {
                    $VictoryArray += 'Blue - Major Victory!'
                    }
                elseif($Difference -ge 10)  #Overwhelming Blue Victory
                    {
                    $VictoryArray += 'Blue - Overwhelming Victory!'
                    $VictoryMultiplier = $VictoryMultiplier*2
                    }
                Else{ #Regular Blue Victory
                    $VictoryArray += 'Blue'
                    }
            $Score = $BlueRolls[$DifferenceCount]*$VictoryMultiplier
            $BlueScore += $Score
            $RedScore += $RedRolls[$DifferenceCount]

            } #End Blue Wins

        elseif ($BlueRolls[$DifferenceCount] -lt $RedRolls[$DifferenceCount]) 
            
            { #Red Win Scenarios

            $Difference = $RedRolls[$DifferenceCount] - $BlueRolls[$DifferenceCount]
            $DifferenceArray += $Difference
            $WinnerArray += 'Red'
                if($Difference -ge 5 -and $Difference -lt 10) #Major Red Victory
                    {
                    $VictoryArray += 'Red - Major Victory!'
                    }
                elseif($Difference -ge 10) #Overwhelming Red Victory
                    {
                    $VictoryArray += 'Red - Overwhelming Victory!'
                    $VictoryMultiplier = $VictoryMultiplier*2
                    }
                Else{$VictoryArray += 'Red'} #Regular Red Victory
            $Score = $RedRolls[$DifferenceCount]*$VictoryMultiplier
            $RedScore += $Score
            $BlueScore += $BlueRolls[$DifferenceCount]
            
            } #End Red Wins

        elseif ($BlueRolls[$DifferenceCount] -eq $RedRolls[$DifferenceCount])
            
            { #Tie Scenario

            $DifferenceArray += 0
            $VictoryArray += 'Tie'
            $WinnerArray += 'Tie'
            $RedScore += $RedRolls[$DifferenceCount]
            $BlueScore += $BlueRolls[$DifferenceCount]
        
            } #End Tie Scenario

        $DifferenceCount++
        $VictoryMultiplier = $PostCritMultiplier
    }#End Difference Loop
        until($DifferenceCount -eq $DieQuantity)

################################################################
## Collect gathered data into custom object for export to csv ##
################################################################
    $csv = For ([int32]$OutputCount = 0; $OutputCount -lt $DieQuantity; $OutputCount++) 
        {
            [pscustomobject] @{
                                'Battle Index' = $BattleIndex[$OutputCount]
                                'Blue Roll' = $BlueRolls[$OutputCount]
                                'Red Roll' = $RedRolls[$OutputCount]
                                'Winner' = $WinnerArray[$OutputCount]
                                'Margin' = $DifferenceArray[$OutputCount]
                                'Crits' = $CritArray[$OutputCount]
                                'Blue Score' = $BlueScore[$OutputCount]
                                'Red Score' = $RedScore[$OutputCount]
                                'Victory' = $VictoryArray[$OutputCount]
                                }
        } 

#########################
## Export to .csv file ##
#########################
    $csv | Export-Csv -Path "$OutputPath\Rolls for $TitleInfo.csv" -NoTypeInformation
    Write-Host "File saved to $OutputPath$TitleInfo.csv"