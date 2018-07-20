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
