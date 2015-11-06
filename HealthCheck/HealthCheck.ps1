##################################################################
#
#  Name:      HealthCheck.ps1
#  Author:    Omid Afzalalghom
#  Date:      02/09/2015
#  Requires:  Excel, PS, SQL Tools.
#  Revisions: 
##################################################################

#Requires –Version 2.0 
$HOST.UI.RawUI.BackgroundColor  = "DarkBlue"
$HOST.UI.RawUI.ForegroundColor  = "White"
   
#Assign variable values.
$dir = split-path -Parent $MyInvocation.MyCommand.Path    
$dir = join-path $dir "\"
$date = get-date -format "yyyyMMdd"

TRY{
    $ErrorActionPreference = "Stop";
     
    #Replace backslash in instance name.
    if ($args[0].IndexOf("\") -gt 0)
      {
    $SQLInstance = $args[0].replace('\','$')  #Instance name passed as parameter from batch file.
    }
    #Replace comma if present due to port number being included.
    elseif  ($args[0].IndexOf(",") -gt 0)
      {
    $SQLInstance = $args[0].replace(',','$')  #Instance name passed as parameter from batch file.
    }
    else {$SQLInstance = $args[0]}

    $DatabaseName = $args[1]		          #Database name passed as parameter from batch file.
    $report = "$dir\Reports\Report_${SQLInstance}_$($args[1])_$date.xlsm"
    $i = 0

    #Import the sqlps module to allow use of invoke-sqlcmd.    
    Import-Module “sqlps” -DisableNameChecking -WarningAction SilentlyContinue 

    #Check database is online.
    Write-Verbose 'Checking database is online.'
    
    $dbState = invoke-sqlcmd –ServerInstance $args[0] -Query "SELECT state_desc FROM sys.databases WHERE name = '$DatabaseName';"  | %{'{0}' -f $_[0]}
    if ($dbState -ne "online")
      {
      "The database '$DatabaseName' is in $dbState mode. Please bring database online and try again."
      sleep -s 5
      return
      }

    #Get SQL Server version and compatibility level of target database.
    [int]$compLevel = invoke-sqlcmd –ServerInstance $args[0] -Query "SELECT compatibility_level FROM sys.databases WHERE name = '$DatabaseName';"  | %{'{0}' -f $_[0]}
    [int]$ver = invoke-sqlcmd –ServerInstance $args[0] -Query "SELECT REPLACE(LEFT(CONVERT(varchar, SERVERPROPERTY ('ProductVersion')),2), '.', '');"  | %{'{0}' -f $_[0]}

    #Set folder path depending upon SQL version.
    if ($ver -eq 9) {$FolderPath = "$dir\Scripts_2005\"}	
        elseif ($ver -eq 10) {$FolderPath = "$dir\Scripts_2008\"}	
        elseif ($ver -eq 11) {$FolderPath = "$dir\Scripts_2012\"}	
        elseif ($ver -eq 12) {$FolderPath = "$dir\Scripts_2014\"}	
         
    $files = get-childitem  -path $FolderPath -filter "*.sql"
    $count = $files.length

    #Run server information script.
    Write-Verbose 'Getting server information.'
    
    powershell.exe -file "$FolderPath\ServerInformation.ps1" $args[0], $dir

    #Loop through the .sql files and run them.
    foreach ($filename in $files | sort-object)
      { 
    	$i++
    	$outfile = "$dir\Reports\Temp\" + $filename.Name.Replace(".sql", "") + ".csv"

    	invoke-sqlcmd –ServerInstance $args[0] -Database $args[1] -InputFile $filename.Fullname |Export-Csv -Path $outfile -NoTypeInformation
    	Write-Progress -activity "Exporting $filename to CSV. File $i/$count." -status "Completed: " -PercentComplete (($i/$count)*100)       
    }

    #For SQL 2005/2008 compatibility 80 databases, run scripts that use CROSS APPLY or UNPIVOT against the master database.
    if ($ver -eq 9 -OR $ver -eq 10 )
    {$FolderPath = "$FolderPath\80\"
     $files = get-childitem -path $FolderPath -filter "*.sql"
        foreach ($filename in $files | sort-object)
          {
        	$outfile = "$dir\Reports\Temp\" + $filename.Name.Replace(".sql", "") + ".csv"
        	invoke-sqlcmd –ServerInstance $args[0] -Database "master" -InputFile $filename.Fullname -Variable "DB='${DatabaseName}'"|Export-Csv -Path $outfile -NoTypeInformation       
        }
    }

    #Create report file.
    copy-item "$dir\Reports\Master.xlsm" -Destination $report -force 

    #Open report file.
    $excel = new-object -comobject excel.application
    $excel.Visible = $False
    $workbook = $excel.workbooks.open($report)   
    $worksheet = $workbook.worksheets.item(1)

    #Run import macro.
    $excel.Run("loader")
     
    #Run formatting macro.
    $excel.Run("FormatWorksheets")

    #Clean up.
    $workbook.close()
    $excel.quit()
    $workbook = $Null
    $worksheet = $Null
    $excel = $Null
     
    #Remove CSVs.
    get-childitem -path $dir\Reports\Temp\ -recurse -filter "*.csv" | remove-item
    
  }
CATCH {
	get-childitem -path $dir\Reports\Temp\ -recurse -filter "*.csv" | remove-item
        Write-output "$(Get-Date –f G) - Error:$filename - $($_.Exception.Message)" | out-file -filepath "$dir\ErrorLog.txt" -append
    }