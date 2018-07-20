Function Update-SPAduserUPNFederatedInformation {
    # .ExternalHelp  .\Update-SPAduserUPNFederatedInformation.xml
    [cmdletbinding(SupportsShouldProcess)]
    param(
    [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true,ParameterSetName="ByUsername")]
    [string[]]$UserName,
    [parameter(ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true,Mandatory=$true,ParameterSetName="BySearchBase")]
    [string]$SearchBase,
    [parameter(ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [string]$ADLocalDomain,
    [parameter(ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [string]$AzureADSyncServerFQDN,
    [parameter(ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [string]$FederatedDomain,
    [parameter(ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [ValidateScript( {Test-Path $_ -PathType Container})]
    [string]$LogFilePath
    )

    BEGIN{

        Function Get-UPNAzureADSyncStatus {
            param(
                [object]$SyncJobStatus
            )
            $Script:ADSyncStauts = $null
            if($SyncJobStatus -eq "Success"){
                $SyncInProgress = $true
                do{
                    $SyncInProgress = Invoke-Command -ComputerName $AzureADSyncServerFQDN -ScriptBlock {Get-ADSyncScheduler | select-object -ExpandProperty SyncCycleInProgress} -ErrorAction Stop
                    if($SyncInProgress -eq $true){
                        Start-Sleep -Seconds 10
                    }#end_SubIF 
                }While($SyncInProgress -eq $true)
                $Script:ADSyncStauts = "Complete"
                return 
            }#END_IF
        }#END_ScriptFunction

        Function Start-UpnUpdateAzureADSync{
            param(
            [String]$ServerName
            )
            filter Out-Default { $_ | Out-Null }
            $JobStatus = "Success"
            $AzureADjobRunStatus = "Running"
            while($AzureADjobRunStatus -eq "Running"){
                Get-UPNAzureADSyncStatus -SyncJobStatus $JobStatus
                if($($Script:ADSyncStauts) -eq "Complete"){
                    $ADSyncStart = Invoke-Command -ComputerName $ServerName -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta} -ErrorAction Stop
                    Return $ADSyncStart.Result
                }#END_IF
            }#While
        }#END_ScriptFunction
    }#BEGIN

    PROCESS{
        Try{
            if($UserName){
                if($PSCmdlet.ShouldProcess($Username)){
                    $DomainUPN = $false
                    $FederatedUPN = $false
                    while($DomainUPN -eq $false){
                            foreach ($AdUser in $UserName){
                                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: UPN to $($ADLocalDomain) for user $($AdUser)"
                                Set-AdUserUPNInformation -UserName $AdUser -Domain $ADLocalDomain -Verbose -ErrorAction Stop
                            }#END_Foreach
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Invoking: Active directory replication $($AzureADSyncServerFQDN)"
                            Start-AdDCSync -logFilePath $LogFilePath -Verbose:$false
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Invoking: AzureAD DeltaSync on server $($AzureADSyncServerFQDN)"
                            $AzureJobStatus = Start-UpnUpdateAzureADSync -ServerName $AzureADSyncServerFQDN
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: AzureAD DeltaSync Job Status on server $($AzureADSyncServerFQDN)"
                            Get-UPNAzureADSyncStatus -SyncJobStatus $AzureJobStatus
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: AzureAD Sync Complete"
                            $DomainUPN = $true
                           
                    }#END_While
                    while($FederatedUPN -eq $false){
                            foreach ($AdUser in $UserName){
                                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: User UPN to $($FederatedDomain) for user $($UserName)"
                                Set-AdUserUPNInformation -UserName $AdUser -Domain $FederatedDomain -Verbose -ErrorAction Stop
                            }#foreaech
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Invoking: Active directory replication $($AzureADSyncServerFQDN)"
                            Start-AdDCSync -logFilePath $LogFilePath -Verbose:$false
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Invoking: AzureAD DeltaSync on server $($AzureADSyncServerFQDN)"
                            $AzureJobStatus = Start-UpnUpdateAzureADSync -ServerName $AzureADSyncServerFQDN
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: AzureAD DeltaSync Job Status on server $($AzureADSyncServerFQDN)"
                            Get-UPNAzureADSyncStatus -SyncJobStatus $AzureJobStatus
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: AzureAD Sync Complete"
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Complete: User UPN updated successfully"
                            $FederatedUPN = $true
                    }#END_While
                }#END_IF
            }#END_IF
            elseif($SearchBase){
                if($PSCmdlet.ShouldProcess($SearchBase)){
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: user UPN to $($ADLocalDomain) in OU $($SearchBase)"
                    Set-AdUserUPNInformation -SearchBase $SearchBase -Domain $ADLocalDomain -Verbose -ErrorAction Stop
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Invoking: Active directory replication $($AzureADSyncServerFQDN)"
                    Start-AdDCSync -logFilePath $LogFilePath -Verbose:$false | Out-Null
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Invoking: AzureAD DeltaSync on server $($AzureADSyncServerFQDN)"
                    $AzureJobStatus = Start-UpnUpdateAzureADSync -ServerName $AzureADSyncServerFQDN
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: AzureAD DeltaSync Job Status on server $($AzureADSyncServerFQDN)"
                    Get-UPNAzureADSyncStatus -SyncJobStatus $AzureJobStatus
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: AzureAD Sync Complete"
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: User UPN to $($FederatedDomain) in OU $($SearchBase)"
                    Set-AdUserUPNInformation -SearchBase $SearchBase -Domain $FederatedDomain -Verbose -ErrorAction Stop
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Invoking: Active directory replication $($AzureADSyncServerFQDN)"
                    Start-AdDCSync -logFilePath $LogFilePath -Verbose:$false | Out-Null
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Invoking: AzureAD DeltaSync on server $($AzureADSyncServerFQDN)"
                    $AzureJobStatus = Start-UpnUpdateAzureADSync -ServerName $AzureADSyncServerFQDN
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: AzureAD DeltaSync Job Status on server $($AzureADSyncServerFQDN)"
                    Get-UPNAzureADSyncStatus -SyncJobStatus $AzureJobStatus
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: AzureAD Sync Complete"
                    Get-ADUser -Filter * -SearchBase $($SearchBase) | Select-Object Name, UserPrincipalName
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Complete: User UPN in OU $($SearchBase) updated successfully"
                }#END_IF
            }#EndElseIF
        }#Try
        Catch{
            $ErrorMessage = $_.Exception.Message
            $ErrorMessage
        }#Catch
    }#PROCESS

    END{

    }#END

}#Function  

# SIG # Begin signature block
# MIIIaAYJKoZIhvcNAQcCoIIIWTCCCFUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUS6no0zX5YuzMHPP94tAJJb1v
# k++gggXMMIIFyDCCBLCgAwIBAgITHwAAAAKXhlLnQ34QXwAAAAAAAjANBgkqhkiG
# 9w0BAQsFADBOMRIwEAYKCZImiZPyLGQBGRYCYXUxEzARBgoJkiaJk/IsZAEZFgNv
# cmcxFDASBgoJkiaJk/IsZAEZFgRBQklPMQ0wCwYDVQQDEwRDQ1JUMB4XDTE4MDcy
# MDAzNDczMFoXDTIwMDcyMDAzNTczMFowZzESMBAGCgmSJomT8ixkARkWAmF1MRMw
# EQYKCZImiZPyLGQBGRYDb3JnMRQwEgYKCZImiZPyLGQBGRYEQUJJTzEOMAwGA1UE
# AxMFVXNlcnMxFjAUBgNVBAMTDUFkbWluaXN0cmF0b3IwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQCNq7s560Wz2Q/s2pZ3sN2r1u0ldKPpGlhhJnzdJMra
# kHKybnUbRB76TY5VBN6t3FDrBMN7qV31gWKn5GHveppDS6gZHVJGQNEcAREpaGgy
# tewEkpmyY7toNSdXn7ydvlqql1AGGu2kGNFA5jEaOqHfm4Nw+Mt0EBfkXXKjSWB5
# 6+0a44feZiAfaGnNUbDq/5P8zgPvnNnrOuKRuagjPy3AehDElk19fDK9ZKOMzu4S
# 11QbPS8Pppc9hOi956d/HysPdKfaCC7UFBlrMagRAOi7M4MDS3JB4heZ5iBcEIBZ
# l7QY6m2NH103YDZ1xUl2cobo196XCiUObCIpZQzbliYPAgMBAAGjggKEMIICgDA9
# BgkrBgEEAYI3FQcEMDAuBiYrBgEEAYI3FQiD9+NKhIacS4eBnT+Gz8FFhKz9TEeB
# vf4ZhaODBgIBZAIBBTATBgNVHSUEDDAKBggrBgEFBQcDAzAOBgNVHQ8BAf8EBAMC
# B4AwGwYJKwYBBAGCNxUKBA4wDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQU162YALpI
# MdSWjsWIwbV0i4A8gk0wHwYDVR0jBBgwFoAUKVmuscbhxWcRNj/GnF+rJD3Fdwcw
# gcoGA1UdHwSBwjCBvzCBvKCBuaCBtoaBs2xkYXA6Ly8vQ049Q0NSVCxDTj1GT1NB
# VU1FTERDMDEsQ049Q0RQLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNl
# cnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9QUJJTyxEQz1vcmcsREM9YXU/Y2Vy
# dGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3Ry
# aWJ1dGlvblBvaW50MIG5BggrBgEFBQcBAQSBrDCBqTCBpgYIKwYBBQUHMAKGgZls
# ZGFwOi8vL0NOPUNDUlQsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2Vz
# LENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9QUJJTyxEQz1vcmcsREM9
# YXU/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNzPWNlcnRpZmljYXRpb25B
# dXRob3JpdHkwNAYDVR0RBC0wK6ApBgorBgEEAYI3FAIDoBsMGUFkbWluaXN0cmF0
# b3JAQUJJTy5vcmcuYXUwDQYJKoZIhvcNAQELBQADggEBAFh89pk6ZQf/o99v1yip
# YpDd1FO3R8aRJIOCVAIrkcY/lWngUPzCftxU3qRMwltFLn7qHIApi1U3H7MAvvBG
# GLvEkJUVI1tXg9NqowwLSggPhtzRH/T/G404UL3c3wRFOqm3ctj66FfqIY2JJRds
# UeX6divBXz6SRYfMko+Yedu7xoab/Uz7FHgQ37NZb6Jn+iqanrty88stDSnSy0Zv
# EvnZkUx1BY3ObVUPht4U/SWYS/O2QoK7AOO2SJMOBHIFDB+nlrB4bKwfAe50bGfG
# x4cGstq3EpBRpHh79A3mFhvjOYrCHMkuo+TKeBD8lKbzatq26rhKYnlskWPH8092
# tu0xggIGMIICAgIBATBlME4xEjAQBgoJkiaJk/IsZAEZFgJhdTETMBEGCgmSJomT
# 8ixkARkWA29yZzEUMBIGCgmSJomT8ixkARkWBEFCSU8xDTALBgNVBAMTBENDUlQC
# Ex8AAAACl4ZS50N+EF8AAAAAAAIwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwx
# CjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGC
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFB54dYskMy4AeGIB
# 8G46uzlZP8cOMA0GCSqGSIb3DQEBAQUABIIBAASuCl9lOHm34kfIZfxyAuujlaYR
# BOGgOH63QaIN/a0gwsQLz+2H7HqtQql5bG1fB8ScymoYVmcrFv0R68oI8TBnIp4k
# 2GIzHupN0aXD5HgspLI5H1w42liYZ41H16U7NNCAEkW9r5wVxvOs7gcakUW918yM
# MPHpY4nYHJVbGlSQgmBvkUQH3ZVRy3fmQm6Y9Z6ZJ0KeC4VclgtEdllSr2EqMkUx
# AqWOid/93RSWt3qLJcq6LA4o2GEYhBHZy7cj15YcIrg97NCKxZTmkuDOLD8pBymK
# cqnWVTc0OYQgcSAkrRMLMXECZ9pE7QSAAcPJpNRY5U0LFbZc6X01POL9OnE=
# SIG # End signature block
