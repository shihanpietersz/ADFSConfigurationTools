---
external help file:
Module Name:
online version:
schema: 2.0.0
---

# Update-TDLFOSAduserUPNFederatedInformation

## SYNOPSIS
Updates Federated UPN information for Active Directory users

## SYNTAX

### ByUsername
```
Update-TDLFOSAduserUPNFederatedInformation -UserName <String[]> -ADLocalDomain <String>
 -AzureADSyncServerFQDN <String> -FederatedDomain <String> -LogFilePath <String> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### BySearchBase
```
Update-TDLFOSAduserUPNFederatedInformation -SearchBase <String> -ADLocalDomain <String>
 -AzureADSyncServerFQDN <String> -FederatedDomain <String> -LogFilePath <String> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This command updates UPN information for users in between two federated domains

## EXAMPLES

### Example 1
```powershell
PS C:\> Update-TDLFOSAduserUPNFederatedInformation -username "Tara.Fisher", "Susan.Yorke", "Almaz.Duggan" -ADLocalDomain 'abio2018.org.au' -FederatedDomain 'afca.org.au' -AzureADSyncServerFQDN "FOSAUMELDC01.ABIO.org.au" -LogFilePath C:\Scripts -Verbose 
```

In the above example the users Tara.Fisher, Susan.Yorke & Almaz.Duggan federated UPN is updated
to afca.org.au and AzureAD is run to update Microsoft Online Services.

### Example 2
```powershell
PS C:\> Update-TDLFOSAduserUPNFederatedInformation -SearchBase "OU=Users,OU=SyncedUsers,DC=ABIO,DC=Org,DC=AU" -ADLocalDomain 'ABIO22.org.au' -FederatedDomain 'afca.org.au' -AzureADSyncServerFQDN "FOSAUMELDC01.ABIO.org.au" -LogFilePath C:\Scripts -Verbose -WhatIf
```

In the above example all users in the Users OU UPN will be updated to the federated UPN of  afca.org.au and AzureAD is run to update Microsoft Online Services.

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
Log File path to AD Replication log
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
if UPN updates needs to be done to all users in an OU. use the SearchBase
in the Base DN format.

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
IF UPN update needs to be done to specific users use the username parameter

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
