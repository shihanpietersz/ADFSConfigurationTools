---
external help file:
Module Name:
online version:
schema: 2.0.0
---

# Update-SPAduserUPNFederatedInformation

## SYNOPSIS
Updates Federated UPN information for Active Directory users

## SYNTAX

### ByUsername
```
Update-SPAduserUPNFederatedInformation -UserName <String[]> -ADLocalDomain <String>
 -AzureADSyncServerFQDN <String> -FederatedDomain <String> -LogFilePath <String> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### BySearchBase
```
Update-SPAduserUPNFederatedInformation -SearchBase <String> -ADLocalDomain <String>
 -AzureADSyncServerFQDN <String> -FederatedDomain <String> -LogFilePath <String> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This command updates UPN information for users in between two federated domains

## EXAMPLES

### Example 1
```powershell
PS C:\> Update-SPAduserUPNFederatedInformation -username "Tara.Fisher", "Susan.Yorke", "Almaz.Duggan" -ADLocalDomain 'adfs.local' -FederatedDomain 'adfstools.com.au' -AzureADSyncServerFQDN "AZADSYNC01.adfs.local" -LogFilePath C:\Scripts -Verbose 
```
users Tara.Fisher, Susan.Yorke & Almaz.Duggan federated UPN is updated
to adfstools.com.au and AzureAD is run to update Microsoft Online Services.

### Example 2
```powershell
PS C:\> Update-SPAduserUPNFederatedInformation -SearchBase "OU=Users,OU=SyncedUsers,DC=users,DC=com,DC=AU" -ADLocalDomain 'adfs.ocal' -FederatedDomain 'adfstools.com.au' -AzureADSyncServerFQDN "AZADSYNC01.adfs.local" -LogFilePath C:\Scripts -Verbose -WhatIf
```

In the above example all users in the Users OU UPN will be updated to the federated UPN of  adfstools.com.au and AzureAD is run to update Microsoft Online Services.

## PARAMETERS

### -ADLocalDomain
Local AD Domian or anyname that is not identified in Microsoft Online Services

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AzureADSyncServerFQDN
AzureADSync Server Name
```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FederatedDomain
Federated domain to update UPN information 

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -LogFilePath
Log File path 
```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SearchBase
if UPN updates needs to be done to all users in an OU. use  SearchBase
in Base DN format.

```yaml
Type: String
Parameter Sets: BySearchBase
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UserName
IF UPN update needs to be done to specific users use username

```yaml
Type: String[]
Parameter Sets: ByUsername
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]
System.String


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
