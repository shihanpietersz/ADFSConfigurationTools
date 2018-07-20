---
external help file:
Module Name:
online version:
schema: 2.0.0
---

# Set-SPUserEmailAddressInformation

## SYNOPSIS
Sets primary and secondary SMTP address for user. Updates Email address attribute to primary SMTP address.

## SYNTAX

### ByUserName
```
Set-SPADUserEmailAddressInformation -UserName <String> -NewSMTPDomain <String> -CurrentSMTPDomain <String>
 [-EnableCurrentSMTPAlias] [-ForceUpdateIfEmpty] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByOU
```
Set-SPADUserEmailAddressInformation -SearchBase <String> -NewSMTPDomain <String>
 -CurrentSMTPDomain <String> [-EnableCurrentSMTPAlias] [-ForceUpdateIfEmpty] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This command sets the users primary SMTP address and updates the existing SMTP address as a
secondary alias if the EnableCurrentSMTPAlias switch is used. 

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-SPADUserEmailAddressInformation -SearchBase "OU=Users,OU=SyncedUsers,DC=ADFS,DC=com,DC=au" -NewSMTPDomain '@adfstools.com.au' -CurrentSMTPDomain '@adfs.com.au' -EnableCurrentSMTPAlias -ForceUpdateIfEmpty -Verbose 
```

The above command sets all users in the OU Users Primary SMTP address to @adfstools.com.au and updates the secondary SMTP alias to @adfs.com.au.

The -forceUpdateifEmpty Parameter will update any users that do not have an email address associated to them


## PARAMETERS

### -CurrentSMTPDomain
Current SMTP domain with the @symbol

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

### -EnableCurrentSMTPAlias
If current SMTP address needs to be updated as a secondary alias.
enable this switch

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ForceUpdateIfEmpty
If no email address detected. enabling the ForceUpdateIFEmpty will update the email address information.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NewSMTPDomain
New SMTP domain with the @symbol

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
searchbase in Base DN format

```yaml
Type: String
Parameter Sets: ByOU
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UserName
Use the Username if only update to a specific user or users are required

```yaml
Type: String
Parameter Sets: ByUserName
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

### System.String


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
