Function Start-AdDCSync {
    [cmdletbinding(SupportsShouldProcess)]
    param(
    [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$false)]
    [ValidateScript( {Test-Path $_ -PathType Container})]
    [String]$logFilePath
    )

    BEGIN{
        Import-Module ActiveDirectory
    }

    PROCESS{
        $DomainName = Get-ADDomain | Select-Object -ExpandProperty DNSRoot 
	    $DC = Get-ADDomain | Select-Object -ExpandProperty Pdcemulator
        $ADPSSession = New-PSSession -ComputerName $DC

        if($PSCmdlet.ShouldProcess($DomainName)){
            $DomainName = Get-ADDomain | Select-Object -ExpandProperty DNSRoot 
            $Date = (get-date).ToString("ddMMyyyy_hh_mm_ss")
           $ReplicationLog = Invoke-Command -Session  $ADPSSession -ScriptBlock {  repadmin /syncall /AdePq }
           $ReplicationLog | Out-File "$($logFilePath)\$($DomainName)_ReplicationLog_$($date).log" -Append
        }#END_IF
    }

    END{
        $ReplicationLog
    }
   
    
}#END_Function
