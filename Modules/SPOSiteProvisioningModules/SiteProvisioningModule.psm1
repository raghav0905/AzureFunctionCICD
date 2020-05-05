# Description: This script contains methods -
#              To connect to SharePoint
#              To generate XML Provisioning Template from Site
#              To add folders and their permissions to XML Provisoning Template
#              To apply Provisioning Template to Site
#              To associate site to HubSite
#              To disable Access Request setting
# Version: 1.0

#To Disable Access Request Setting
function Disable-AccessRequest {
    Begin {
        Write-Output "Disabling Access Request setting on the site"
    }

    Process {
        try {
            $ctx = Get-PnPContext
            $web = $ctx.Web
            $ctx.Load($web)

            #Disable Access request
            $web.RequestAccessEmail = ""
            $ctx.ExecuteQuery()
            Write-Output "Access Request setting is successfully disabled for this site"
        }
        catch {
            Write-Output $_.Exception.Message
        }
    }

    End {

    }

}

#To create site without Office 365 groups
function Create-SiteWithoutO365Group {
    [CmdletBinding()]
    Param
    (
        [string] $StoreLinkItemName,
        [string] $SiteURL,
        [string] $Owner 
    )

    Begin {
        Write-Output "Creating site without O365 groups" 
    }

    Process {
        try {
            New-PnPTenantSite `
            -Title $StoreLinkItemName `
            -Url $SiteURL `
            -Description $StoreLinkItemName `
            -Owner $Owner `
            -Lcid 1033 `
            -Template "STS#3" `
            -TimeZone 10 `
            -Wait -ErrorAction SilentlyContinue -ErrorVariable ProcessError

            return $ProcessError
        }
        catch {
            Write-Output $_.Exception.Message
        }
    }

    End {

    }
}

#To Associate connected site to HubSite
function Associate-ToSPOHubSite {
    [CmdletBinding()]
    Param
    (
        [string] $siteUrl,
        [string] $hubSiteUrl
    )

    Begin {
        Write-Output "Associating this site to hubsite."
    }

    Process {
        try {
            Add-PnPHubSiteAssociation -Site $siteUrl -HubSite $hubSiteUrl
            Write-Output "Connected site associated to hubsite successfully."
        }
        catch {
            Write-Output $_.Exception.Message
        }
    }

    End {

    }
}

#To apply Provisioning Template to connected Site
function  Apply-SPOProvisioningTemplate {
    [CmdletBinding()]
    Param
    (
        [string] $siteTemplatePath,
        [string] $siteTemplateName
    )

    Begin {
        Write-Output "Applying Provisioning template to connected site"
    }

    Process {
        try {

            #Applying XML Provisioning Template to Connected Site
            Apply-PnPProvisioningTemplate -Path "$siteTemplatePath\$siteTemplateName" -ClearNavigation -ErrorAction Stop
            Write-Output "Template provisioning completed."
            return $true
        }
        catch {
            Write-Output "Exception Message: $($_.Exception.Message)"
            return $false
        }
    }

    End {

    }
}


#To apply Formula in calculated column
function  Update-FormulainColumn {
    [CmdletBinding()]
    Param
    (
        [string] $listName,
        [string] $fieldName,
        [string] $formula
    )

    Begin {
        Write-Output "Applying formula in column"
    }

    Process {
        try {

            $field = Get-PnPField -List $listName -Identity $fieldName
            [xml]$schemaXml=$field.SchemaXml
            $schemaXml.Field.Formula=$formula
            Set-PnPField -List $listName -Identity $fieldName -Values @{SchemaXml=$schemaXml.OuterXml}

        }
        catch {
            Write-Output $_.Exception.Message
        }
    }

    End {

    }
}

#To Removing Preservation Hold Library from site template (For Library only)
function Remove-PreservationHoldLibrary {
    [CmdletBinding()]
    Param
    (
        [string] $siteTemplateName,
        [string] $siteTitle,
        [string] $siteTemplatePath
    )

    Begin {
        Write-Output "Adding Folders to Provisioning template"
    }

    Process {
        try {
            
           
            #Reading Generated Template File
            Write-Output "Reading XML File"
            [XML]$siteTemplate = Get-Content -Path "$siteTemplatePath\$siteTemplateName" -ErrorAction Stop

            # Removing Preservation Hold Library from site template
            $siteTemplate.Provisioning.Templates.ProvisioningTemplate.Lists.ListInstance | Where-Object {$_.TemplateType -eq '1310'} | ForEach-Object {$_.ParentNode.RemoveChild($_)}

            $siteTemplate.Save("$siteTemplatePath\$siteTemplateName")
        }
        catch {
            Write-Output $_.Exception.Message
        }
    }

    End {

    }
}

#To remove JSLink from Site Columns
function Remove-JSLinkFieldsFromProvTemplate {
    [CmdletBinding()]
    Param
    (
        [string] $siteTemplatePath,
        [string] $siteTemplateName
    )

    Begin {
        Write-Output "Updating Provisioning template to remove JSLink fields from Site Fields"
    }

    Process {
        try {
            #Reading Generated Template File
            Write-Output "Reading XML File"
            [XML]$siteTemplate = Get-Content -Path "$siteTemplatePath\$siteTemplateName" -ErrorAction Stop
            
            #Removing JSLink from Site Fields
            $siteTemplate.Provisioning.Templates.ProvisioningTemplate.SiteFields.Field | Where-Object {$null -ne $_.JSLink} | ForEach-Object {$_.ParentNode.RemoveChild($_)}
            $siteTemplate.Save("$siteTemplatePath\$siteTemplateName")
        }
        catch {
            Write-Output $_.Exception.Message
        }
    }

    End {

    }
}

#To get Provisioning Template from connected Site
function Get-SPOSiteTemplate {
    [CmdletBinding()]
    Param
    (
        [string] $siteTemplateName,
        [string] $siteTemplatePath
    )

    Begin {
        Write-Output "Getting Provisioning template from Connected Site"
    }

    Process {
        try {

            Get-PnPProvisioningTemplate -Out "$siteTemplatePath\$siteTemplateName" -PersistBrandingFiles -PersistComposedLookFiles -IncludeSiteGroups -ExcludeContentTypesFromSyndication -Force 
            Write-Output "Generated the Provisioning template successfully."

        }
        catch {
            Write-Output $_.Exception.Message
        }
    }

    End {

    }
}

#To connect to SPO Site using AppId, AppSecret
function Connect-Site {
    [CmdletBinding()]
    Param
    (
        [string] $domain,
        [string] $siteUrl,
        [string] $clientId,
        [string] $certificate,
        [string] $key
    )

    Begin {
        Write-Output "Connecting to site- '$siteUrl'"
    }

    Process {
        try {
            Connect-PnPOnline -Url $siteUrl -ClientId $clientId -Tenant $domain -PEMCertificate $certificate -PEMPrivateKey $key
            Write-Output "Connected to site successfully."
        }
        catch {
            Write-Output $_.Exception.Message
        }
    }

    End {

    }
}
