---
external help file:
Module Name:
online version:
schema: 2.0.0
---

# Update-TDLFOSADFSWebApplicationProxyURL

## SYNOPSIS
Updates ADFS Webapplication proxy URL with new federated domain name

## SYNTAX

```
Update-TDLFOSADFSWebApplicationProxyURL [-NewFederatedDomainURL] <String> [-CurrentFederatedDomainURL] <String>
 [-WebApplicationProxyHostName] <String> [-DomainUsername] <String> [-DomainPassword] <String>
 [-CertificateThumbprint] <String> [-LogFilePath] <String> [<CommonParameters>]
```

## DESCRIPTION
this command updates the Webapplication server with the new federated domain URL

## EXAMPLES

### Example 1
```powershell
PS C:\> Update-ADFSWebApplicationProxyURL -CurrentFederatedDomainURL "sso.fos.org.au" -NewFederatedDomainURL "sso.afca.org.au" -WebApplicationProxyHostName 'FOSAUMELSRV003' -DomainUsername 'abio\Administrator' -DomainPassword 'Pa$$w0rd' -CertificateThumbprint 'EA4FB1FABBE3746C85A0CAC94B761C9D84BF7CE1' -LogFilePath 'C:\Scripts' -Verbose
```

The above example updates the new federated domain from sso.fos.org.au to sso.afca.org.au

## PARAMETERS

### -CertificateThumbprint
Thumbprint of new Federated domain name
Use get-childitem Get-ChildItem Cert:\LocalMachine\My

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -CurrentFederatedDomainURL
Current federated domain URL

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DomainPassword
Active directory domain password

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DomainUsername
Active Directory domain username

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -LogFilePath
Log File path

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NewFederatedDomainURL
new federated domain URL

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -WebApplicationProxyHostName
webapplication proxy server hostname

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
