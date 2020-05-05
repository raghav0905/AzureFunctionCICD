function CopyLists{
    [CmdletBinding()]
     Param(  
      [Parameter(Mandatory=$True)]
     [string]
     $clientId, 
     [Parameter(Mandatory=$True)]
     [string]
     $certificate, 
     [Parameter(Mandatory=$True)]
     [string]
     $key,
     [Parameter(Mandatory=$True)]
     [string]
     $domain,
     [Parameter(Mandatory=$True)]
     [string]
     $sourceSiteURL,
     [Parameter(Mandatory=$True)]
     [string]
     $destinationSiteURL,
     [Parameter(Mandatory=$True)]
     [string]
     $templateType
     ) 
 
     Try {
            #Initializing variable to store destination lists name 
            $targetLists = ($env:TARGETLISTSARRAY).split(';')
            #Loop through Each of above Target lists
            foreach ($tList in $targetLists) {
                #Check the Template type
                if ($templateType -eq $env:TEMPLATENAMEBRANDSTORE) {
                    #Initializing variable to store source list name for BrandStore
                    $sourceList = $templateType + '_' + $tList.Replace(' ', '')
    
                }
                elseif ($templateType -eq $env:TEMPLATENAMEFLAGSHIP) {
                    #Initializing variable to store source list name for FlagShipStore
                    $sourceList = $templateType + '_' + $tList.Replace(' ', '')
                }
                #Copy items to each of target list
                switch ($tList) {
                    #Copy items to each of Status list
                    "Status" {
                        $sourceList = "Status"
                        $listFields = ($env:STATUSLISTFIELDS).split(';')  
                        CopyListItem -sourceSiteURL $sourceSiteURL -sourceList $sourceList -destinationSiteURL $destinationSiteURL -targetList $tList -listFields $listFields  -clientId $clientId -certificate $certificate -key $key -domain $env:DOMAIN
                        break
                    }
                    #Copy items to each of Project Contacts list
                    "Project Contacts" {
                        $listFields = ($env:PROJECTCONTACTSLISTFIELDS).split(';')
                        CopyListItem -sourceSiteURL $sourceSiteURL -sourceList $sourceList -destinationSiteURL $destinationSiteURL -targetList $tList -listFields $listFields -clientId $clientId -certificate $certificate -key $key -domain $env:DOMAIN
                        break
                    }
                    #Copy items to each of Quick Links list
                    "Quick Links" {
                        $listFields = ($env:QUICKLINKSLISTFIELDS).split(';') 
                        CopyListItem -sourceSiteURL $sourceSiteURL -sourceList $sourceList -destinationSiteURL $destinationSiteURL -targetList $tList -listFields $listFields -clientId $clientId -certificate $certificate -key $key -domain $env:DOMAIN
                        break
                    }
                    #Copy items to each of StreamPlans list
                    "Stream Plans" {
                        $sourceList = "Stream Plans"
                        $listFields = ($env:STREAMPLANSLISTFIELDS).split(';')
                        CopyStreamListItem -templateType $templateType -sourceSiteURL $sourceSiteURL -sourceList $sourceList -destinationSiteURL $destinationSiteURL -targetList $tList -listFields $listFields -clientId $clientId -certificate $certificate -key $key -domain $env:DOMAIN
                        break   
                    }   
                    "Key Location Info" {
                        $sourceList = "Key Location Info"
                        $listFields = ($env:KEYLOCATIONINFOLISTFIELDS).split(';')
                        CopyListItem -sourceSiteURL $sourceSiteURL -sourceList $sourceList -destinationSiteURL $destinationSiteURL -targetList $tList -listFields $listFields -clientId $clientId -certificate $certificate -key $key -domain $env:DOMAIN
                        break   
                    }  
                    default { break }
                }
    
            }
            Disconnect-PnPOnline
         }
 
     Catch {
         $ErrorMessage = $_.Exception.Message
         Write-Output $ErrorMessage;
     }
 }

function CopyListItem {
    [CmdletBinding()]
     Param(  
      [Parameter(Mandatory=$True)]
     [string]
     $clientId, 
     [Parameter(Mandatory=$True)]
     [string]
     $certificate, 
     [Parameter(Mandatory=$True)]
     [string]
     $key,
     [Parameter(Mandatory=$True)]
     [string]
     $domain,
     [Parameter(Mandatory=$True)]
     [string]
     $sourceSiteURL,    
     [Parameter(Mandatory=$True)]
     [string]
     $sourceList, 
     [Parameter(Mandatory=$True)]
     [string]
     $destinationSiteURL,
     [Parameter(Mandatory=$True)]
     [string]
     $targetList,
     [Parameter(Mandatory=$True)]
     [array]
     $listFields
     ) 
 
     Try {
 
         #Connect to source site using the connector script to get the Souce context..  
         Connect-Site -siteUrl $sourceSiteURL -clientId $clientId -certificate $certificate -key $key -domain $domain
 
         #Retrieves items from the source list
         $sourcelistItems = Get-PnPListItem -List $sourceList -Fields $listFields 
 
         #Total Items count for source list
         $sourceitemCount=$sourcelistItems.Count
         
         $msg = "Copying items from list : " + $sourcelist + " to list : " + $targetList
         Write-Output $msg
         
         #Check if list is not empty
         if($sourceitemCount -ne 0) { 
             # Connect to destination site using the connector script
             Connect-Site -siteUrl $destinationSiteURL -clientId $clientId -certificate $certificate -key $key -domain $domain
 
             #Retrieves items from the destination list
             $destlistItems = Get-PnPListItem -List $targetList            
             #Total Items count for destination list
             $destitemCount = $destlistItems.Count
 
             #Check if list is not empty then delete all items in list
             if($destitemCount -ne 0) {
                Write-Output "Deleting existing items"
                 foreach($item in $destlistItems) {
                     Remove-PnPListItem -List $targetList -Identity $item.Id -Force                
                 }                                 
             }           
             
         #Assign Global variable HashTable to store column values from source list to target list
         $global:hashTable =$null;
         $global:hashTable = @{}
             #Add List Items to Target List                
             foreach($listItem in $sourcelistItems) { 
                 for($i=0; $i -lt $listFields.length; $i++){           
                     $columnName =  $listFields[$i]           
                     $itemcolumnValue= $listItem[$columnName]            
                     $global:hashTable.Add($columnName,$itemcolumnValue)
                 }
                 Add-PnpListItem -List $targetList -Values $global:hashTable
                 $global:hashTable.Clear();
             } 
         }
 
         else {
             Write-Output 'WARNING - Target List is not empty!';
         }
         Write-Output 'SUCCESS - all items from source list to destination list have been copied successfully.';
     }
 
     Catch {
         $ErrorMessage = $_.Exception.Message
         Write-Output $ErrorMessage;
     }
 }
 
 function CopyStreamListItem {
    [CmdletBinding()]
     Param(  
      [Parameter(Mandatory=$True)]
     [string]
     $clientId, 
     [Parameter(Mandatory=$True)]
     [string]
     $certificate, 
     [Parameter(Mandatory=$True)]
     [string]
     $key,
     [Parameter(Mandatory=$True)]
     [string]
     $domain,
     [Parameter(Mandatory=$True)]
     [string]
     $sourceSiteURL,    
     [Parameter(Mandatory=$True)]
     [string]
     $sourceList, 
     [Parameter(Mandatory=$True)]
     [string]
     $destinationSiteURL,
     [Parameter(Mandatory=$True)]
     [string]
     $targetList,
     [Parameter(Mandatory=$True)]
     [array]
     $listFields,
     [Parameter(Mandatory=$True)]
     [string]
     $templateType
     ) 
 
     Try {
 
         #Connect to source site using the connector script to get the Souce context..  
         Connect-Site -siteUrl $sourceSiteURL -clientId $clientId -certificate $certificate -key $key -domain $domain
 
         $camlQuery = "<View><Query><Where><Or><Eq><FieldRef Name='Template' /><Value Type='Choice'>Both</Value></Eq><Eq><FieldRef Name='Template' /><Value Type='Choice'>" + $templateType + "</Value></Eq></Or></Where></Query></View>"
         
         #Retrieves items from the source list
         $sourcelistItems =   Get-PnPListItem -List $sourcelist  -Query $camlQuery
 
         #Total Items count for source list
         $sourceitemCount=$sourcelistItems.Count
         
         $msg = "Copying items from list : " + $sourcelist + " to list : " + $targetList
         Write-Output $msg
         
         #Check if list is not empty
         if($sourceitemCount -ne 0) { 
             # Connect to destination site using the connector script
             Connect-Site -siteUrl $destinationSiteURL -clientId $clientId -certificate $certificate -key $key -domain $domain
 
             #Retrieves items from the destination list
             $destlistItems = Get-PnPListItem -List $targetList            
             #Total Items count for destination list
             $destitemCount = $destlistItems.Count
 
             #Check if list is not empty then delete all items in list
             if($destitemCount -ne 0) {
                Write-Output "Deleting existing items"
                 foreach($item in $destlistItems) {
                     Remove-PnPListItem -List $targetList -Identity $item.Id -Force                
                 }                                 
             }           
             
         #Assign Global variable HashTable to store column values from source list to target list
         $global:hashTable =$null;
         $global:hashTable = @{}
             #Add List Items to Target List                
             foreach($listItem in $sourcelistItems) { 
                 for($i=0; $i -lt $listFields.length; $i++){           
                     $columnName =  $listFields[$i]           
                     $itemcolumnValue= $listItem[$columnName]            
                     $global:hashTable.Add($columnName,$itemcolumnValue)
                 }
                 Add-PnpListItem -List $targetList -Values $global:hashTable
                 $global:hashTable.Clear();
             } 
         }
 
         else {
             Write-Output 'WARNING - Target List is not empty!';
         }
         Write-Output 'SUCCESS - all items from source list to destination list have been copied successfully.';
     }
 
     Catch {
         $ErrorMessage = $_.Exception.Message
         Write-Output $ErrorMessage;
     }
 }
 
 