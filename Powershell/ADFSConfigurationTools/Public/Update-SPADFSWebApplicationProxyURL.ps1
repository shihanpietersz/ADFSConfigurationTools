Function Update-SPADFSWebApplicationProxyURL {
    # .ExternalHelp  .\Update-SPADFSWebApplicationProxyURL.xml
    param(
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$NewFederatedDomainURL,
          [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$CurrentFederatedDomainURL,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$WebApplicationProxyHostName,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$DomainUsername,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$DomainPassword,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$CertificateThumbprint,
        [parameter(ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [ValidateScript( {Test-Path $_ -PathType Container})]
        [string]$LogFilePath
    )

    BEGIN{
        try{
            
            $DomainCred = New-MsolSecurePassword  -UserName $DomainUsername -KeyFile "$LogFilePath\Domainkeyfile.txt" -PlainTextPassword $DomainPassword -PasswordFile "$LogFilePath\DomainSecurePass.txt" -Byte 32 -ErrorAction Stop
            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Opening: Powershell Session to $($WebApplicationProxyHostName)"
            $ADFSPSSession = New-PSSession -ComputerName $WebApplicationProxyHostName -ErrorAction Stop
        }
        Catch{
            $ErrorMessage = $_.Exception.Message
            $ErrorMessage
        }
    }#BEGIN_END

    PROCESS{
        try{
            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Installing: New WebApplication proxy settings"
            $URL1 = "netsh http delete sslcert hostnameport=$($CurrentFederatedDomainURL):443"
            $URL2 = "netsh http delete sslcert hostnameport=$($CurrentFederatedDomainURL):49443"
            $RemoveSSLCerts = Invoke-Command -Session $ADFSPSSession -ScriptBlock {
                 & cmd /c $args[0]
                 & cmd /c $args[1]
                 & cmd /c netsh http delete cache  
            } -ArgumentList $URL1, $URL2 -ErrorAction Stop
            
            $InsWebAppProxy = Invoke-Command -Session $ADFSPSSession -ScriptBlock {
                Set-WebApplicationProxySslCertificate -Thumbprint $args[0]
                Install-WebApplicationProxy -CertificateThumbprint $Args[0] -FederationServiceName $Args[1] -FederationServiceTrustCredential $args[2]
            } -ArgumentList $CertificateThumbprint, $NewFederatedDomainURL, $DomainCred -ErrorAction Stop

            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: WebApplicationProxyConfiguraion"
            Invoke-Command -Session $ADFSPSSession -ScriptBlock {
                Set-WebApplicationProxyConfiguration -ADFSUrl "https://$($Args[0])/adfs/ls" -OAuthAuthenticationURL "https://$($Args[0])/adfs/oauth2/authorize"
            } -ArgumentList $NewFederatedDomainURL, $DomainCred
            $CurrentWebApps = Get-WebApplicationProxyConfiguration
            $CurrentWebApps | Tee-Object -FilePath "$($logFilePath)\WebApplicationConfigurations_$($date).log" -Append
            Get-Service adfssrv | Restart-Service
        }#Try_END
        Catch{
            $ErrorMessage = $_.Exception.Message
            $ErrorMessage
        }#Catch_END
    }#PROCESS_END

    END{
        Write-Verbose "[$((get-date).TimeOfDay.ToString()) END ] Remove: Removing PSSessions on $($PrimaryADFSServer)"
        $ADFSPSSession | Remove-PSSession
    }#END

}#Function



