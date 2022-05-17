#Changeable Variables
$serverName = '' #Name of device or server
$user = '' #Username to query
$taskArray = @('','') #Add task names with extensions, if applicable

########################################################################################################################################

#Static Variables
$message = '' #Variable for error message
$userList = query user $user /server:$serverName #Get users signed into specified server
$stat = 0 #Default statistic variable
$exitCode = 0 #Setting the Exit Code to 0 Tells Solarwinds there is not an issue

if($userList -NotMatch $user) { #If user is signed in
    for($i=0; $i -le $taskArray.Length; $i++) {
    $processes = @($taskArray[$i]) | ` % {
            $results += Get-WMIObject Win32_Process -computer $serverName -filter "Name='$_'" | select -expand path 
            if($results -notmatch $taskArray[$i]) { #If NOT running
                #Change statistic message
                $message += "There is an issue with "+$taskArray[$i]+"`n" #Can be changed
                #Setting the Exit Code to 2 Tells Solarwinds there is an issue
                $ExitCode = 2
            }
            $results = $null #Clear results
        }
    }
}
else { #If user is NOT signed in
    #Change statistic message
    $message = "The "+$user+" needs to be signed in!"
    #Setting the Exit Code to 2 Tells Solarwinds there is an issue
    $ExitCode = 2
}

Write-Host "Statistic:" $stat
Write-Host "Message:" $message
Exit $exitCode