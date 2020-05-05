# Description: This script contains methods -
#              To get secrets from Azure Key Vault
# Version: 1.0

#To get secrets from KeyVault
function Get-SecretsFromKeyVault {
    [CmdletBinding()]
    Param
    (
        [string] $endPoint,
        [string] $secret,
        [string] $vaultURI
    )

    Begin {
        
    }

    Process {
        try {
            
            # Vault URI to get AuthN Token
            $vaultTokenURI = 'https://vault.azure.net&api-version=2017-09-01'

            # Create AuthN Header with our Function App Secret
            $header = @{'Secret' = $secret}

            # Get Key Vault AuthN Token
            $authenticationResult = Invoke-RestMethod -Method Get -Headers $header -Uri ($endpoint +'?resource=' +$vaultTokenURI)
            
            # Use Key Vault AuthN Token to create Request Header
            $requestHeader = @{ Authorization = "Bearer $($authenticationResult.access_token)" }

            # Call the Vault and Retrieve Client Id
            $secretValue = Invoke-RestMethod -Method GET -Uri $vaultURI$env:KVAPIVERSIONURI -ContentType 'application/json' -Headers $requestHeader          
            
            return $($secretValue.Value)
        }
        catch {
            Write-Output $_.Exception.Message
        }
    }

    End {

    }
}