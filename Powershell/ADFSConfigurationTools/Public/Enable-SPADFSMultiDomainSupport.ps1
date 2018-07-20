
Function Enable-SPADFSMultiDomainSupport {
    # .ExternalHelp  .\Enable-SPADFSMultiDomainSupport.xml
    [cmdletbinding(SupportsShouldProcess)]
    param( 
    [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [String]$PrimaryADFSServer,
    [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [String]$MsolUserName,
    [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [String]$MsolPassword,
    [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [String]$NewDomainToFederate
    )

    BEGIN{
        $SecureCred = New-MsolSecurePassword  -UserName $MsolUserName -KeyFile "$PSScriptRoot\keyfile.txt" -PlainTextPassword $MsolPassword -PasswordFile "$PSScriptRoot\SecurePass.txt" -Byte 32 -ErrorAction Stop
        $ADFSPSSession = New-PSSession -ComputerName $PrimaryADFSServer
    }

    PROCESS{
        Try{
            $NewFederationSupportStatus += @()
            $ADFSCurrentFederatedDomainInfo += @()
            $MsolCurrentdDomainInfo += @()
            $NewFederationStatus = $false
            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: Active Federated Domains"
            
                $MsolCurrentdDomainInfo = Invoke-Command -Session $ADFSPSSession -ScriptBlock `
                {
                    Connect-MsolService -Credential $Args[0]
                    Get-MsolDomain 
                } -ArgumentList $SecureCred -ErrorAction stop
                
                foreach ($Domain in $MsolCurrentdDomainInfo){
                    $ADFSCurrentFederatedDomainInfo += $Domain | Where-Object {$_.Authentication -eq "Federated"}
                }#Foreach_END
                
                
                foreach ($FDDoman in $ADFSCurrentFederatedDomainInfo){
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Information: Domain $($FDDoman.Name) is $($FDDoman.Authentication)"   
                }#Foreach_END
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Information: Total Federated Domains found  $($ADFSCurrentFederatedDomainInfo.count)"        
        

            if($PSCmdlet.ShouldContinue("Temporary Service interruptions will occur during ADFS federation of  Domain $($NewDomainToFederate)", 'Confirm ?')){
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Removing: Removing Relaying PartyTrust on primary ADFS Server $($PrimaryADFSServer)"
                Invoke-Command -ComputerName $PrimaryADFSServer -ScriptBlock `
                {
                Get-AdfsRelyingPartyTrust | Where-Object {$_.Name -eq "Microsoft office 365 Identity Platform"} | Remove-AdfsRelyingPartyTrust
                } -ErrorAction Stop
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Remove: Complete"
                foreach($FD in $ADFSCurrentFederatedDomainInfo.Name){
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: Existing federated domain to support Multidomain"
                    
                        $FDDomainUpdate = Invoke-Command -Session $ADFSPSSession -ScriptBlock `
                        {
                            Connect-MsolService -Credential $Args[0]
                            Update-MsolFederatedDomain  -DomainName $Args[1] -SupportMultipledomain
                        }  -ArgumentList $SecureCred, $FD -ErrorAction Stop
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: $($FDDomainUpdate) to support Multidomain"    
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: $($NewDomainToFederate) as federated domain and enabling Multidomain support"
                    if($NewFederationStatus -eq $false){
                        $NewFederationSupportStatus += Invoke-Command -Session $ADFSPSSession -ScriptBlock `
                        {
                        Connect-MsolService -Credential $Args[0]    
                        Convert-MsolDomainToFederated -DomainName $Args[1] -SupportMultipledomain
                        Update-MsolFederatedDomain -domainName $Args[1] -SupportMultipleDomain 
                        Get-Service adfssrv | Restart-Service
                        } -ArgumentList $SecureCred, $NewDomainToFederate -ErrorAction Continue
                    }#IF_END
                    $NewFederationStatus = $true

                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Informaton: Status MultiDomain $($NewFederationSupportStatus)"
                }#foreach_END
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Informaton: Operation Complete"
            }#END_IF
        }#Try_END
        Catch{
            $ErrorMessage = $_.Exception.Message
            throw $ErrorMessage
        }#Catch_END
    }#Process

    END{
        
        Write-Verbose "[$((get-date).TimeOfDay.ToString()) END ] ServiceRestart:  restarting Adfssrv service on $($PrimaryADFSServer)"
        Invoke-Command -Session $ADFSPSSession -ScriptBlock {Get-Service adfssrv | Restart-Service}
        Write-Verbose "[$((get-date).TimeOfDay.ToString()) END ] Remove: Removing PSSessions on $($PrimaryADFSServer)"
        $ADFSPSSession | Remove-PSSession
    }

}#End_Function  
