# Description: This script contains methods -
#              to trace log
# Version: 1.0

# Set tracelog status and tracelog level
function Set-TraceLog {
    [CmdletBinding()]
    Param
    (
        [string] $FilePath,
        [string] $FileName,
        [string] $Level,
        [string] $Status
    )

    Begin {
        Write-Output "Start tracelog"
        $LogTime = Get-Date -Format "yyyy-MM-dd_hh"
        $LogPath = $FilePath + $LogTime +"_" + $Level +"_" +$FileName
    }

    Process {
        try 
        {
            if($Status -eq "On")
            {
                Set-PnPTraceLog -On -LogFile $LogPath -Level $Level
            }
            else
            {
                Set-PnPTraceLog -Off -LogFile $LogPath -Level $LogLevel
            }
           
        }
        catch {
            Write-Output $_.Exception.Message
        }
    }

    End {

    }
}