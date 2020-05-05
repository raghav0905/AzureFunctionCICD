# Description: This script contains methods -
#              to move template in archive folder
# Version: 1.0


# Move Template file to archive
function Move-TemplateToArchive {
    [CmdletBinding()]
    Param
    (
        [string] $sourceFilePath,
        [string] $destinationFilePath,
        [string] $sourceSiteName
    )

    Begin {
            #Creating variable to hold datetime
            $LogTime = Get-Date -Format "MM-dd-yyyy_hh_mm"
            
            #Setting log file path
            $destinationFilefullPath = $destinationFilePath + $sourceSiteName +"_" +$LogTime+".xml"
            
            #temp source file path 
            $tempPath = $sourceFilePath
            
            #Orignal file name
            $OrignalFileName = $sourceSiteName + '.xml'
            
            $fileMoved = $false
            
            #Orignal file path
            $sourceFilePath = $sourceFilePath.Replace("_temp","")
        }

    Process {
            try {
            # Checking file exist or not in source path
            $isFileExist = Test-Path -path $sourceFilePath
            $isTempFileExist = Test-Path -path $tempPath
            $isArchiveFolderExist = Test-Path -path $destinationFilePath
            if($isArchiveFolderExist -ne $true)
            {
                New-Item -ItemType directory -Path $destinationFilePath
            }
            If($isFileExist -and $isTempFileExist){
                Write-Output "Archiving old template."
                
                # Moving source template to destination template
                Move-Item -Path $sourceFilePath -Destination $destinationFilefullPath 
                
                #Rename temp file with orginal name
                Rename-Item -Path $tempPath -NewName $OrignalFileName
                Write-Output "Template renamed with category name"
                
                Write-Output "Old Template successfully moved to archive folder."
                
                $fileMoved = $true
            }
            elseif($isTempFileExist){
            
                #Rename temp file with orginal name
                Rename-Item -Path $tempPath -NewName $OrignalFileName
                Write-Output "Template renamed with category name"
                $fileMoved = $true
            }
            else{
                Write-Output "Something went wrong"
                 $fileMoved = $false
            }
        }
        catch {
            Write-Output $_.Exception.Message
           }
    }

    End {
        return $fileMoved
    }
}