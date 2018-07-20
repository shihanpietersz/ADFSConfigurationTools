---
external help file:
Module Name:
online version:
schema: 2.0.0
---

# Update-SPADFSWebApplicationProxyURL

## SYNOPSIS
Updates ADFS Webapplication proxy URL with new federated domain name

## SYNTAX

```
Update-SPADFSWebApplicationProxyURL [-NewFederatedDomainURL] <String> [-CurrentFederatedDomainURL] <String>
 [-WebApplicationProxyHostName] <String> [-DomainUsername] <String> [-DomainPassword] <String>
 [-CertificateThumbprint] <String> [-LogFilePath] <String> [<CommonParameters>]
```

## DESCRIPTION
This command updates the Web application proxy server with the new federated domain URL

## EXAMPLES

### Example 1
```powershell
PS C:\> Update-SPADFSWebApplicationProxyURL -CurrentFederatedDomainURL "sso.adfs.com.au" -NewFederatedDomainURL "sso.adfstools.com.au" -WebApplicationProxyHostName 'ADFSWEBAPP01' -DomainUsername 'ADFS\Administrator' -DomainPassword 'Pa$$w0rd' -CertificateThumbprint 'EA4FB1EWBBE3746C85AAWAC94B761C9D2ABF7C22' -LogFilePath 'C:\Scripts' -Verbose
```

The above example updates the new federated domain from sso.adfs.com.au to sso.adfstools.com.au

## PARAMETERS

### -CertificateThumbprint
Certificate Thumbprint of new Federated domain name


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
Webapplication proxy server hostname

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
