Function DecodeUserAccountControl ([int]$UAC)
{
$UACPropertyFlags = @(
"SCRIPT",
"ACCOUNTDISABLE",
"RESERVED",
"HOMEDIR_REQUIRED",
"LOCKOUT",
"PASSWD_NOTREQD",
"PASSWD_CANT_CHANGE",
"ENCRYPTED_TEXT_PWD_ALLOWED",
"TEMP_DUPLICATE_ACCOUNT",
"NORMAL_ACCOUNT",
"RESERVED",
"INTERDOMAIN_TRUST_ACCOUNT",
"WORKSTATION_TRUST_ACCOUNT",
"SERVER_TRUST_ACCOUNT",
"RESERVED",
"RESERVED",
"DONT_EXPIRE_PASSWORD",
"MNS_LOGON_ACCOUNT",
"SMARTCARD_REQUIRED",
"TRUSTED_FOR_DELEGATION",
"NOT_DELEGATED",
"USE_DES_KEY_ONLY",
"DONT_REQ_PREAUTH",
"PASSWORD_EXPIRED",
"TRUSTED_TO_AUTH_FOR_DELEGATION",
"RESERVED",
"PARTIAL_SECRETS_ACCOUNT"
"RESERVED"
"RESERVED"
"RESERVED"
"RESERVED"
"RESERVED"
)
$Attributes = ""
1..($UACPropertyFlags.Length) | Where-Object {$UAC -bAnd [math]::Pow(2,$_)} | ForEach-Object {If ($Attributes.Length -EQ 0) {$Attributes = $UACPropertyFlags[$_]} Else {$Attributes = $Attributes + " | " + $UACPropertyFlags[$_]}}
Return $Attributes
}

$Users = Get-ADUser -SearchBase "OU=ANZ Operations,DC=vt,DC=local" -Filter * -Properties CanonicalName, PasswordExpired, LastLogonDate, PasswordLastSet, PasswordNeverExpires, PasswordNotRequired, MemberOf, Description, Created, userAccountControl, CannotChangePassword, LockedOut, AccountExpirationDate
$Report = @()

Foreach($User in $Users){
    $UserOU = $User.CanonicalName -replace "/$($User.Name)",""
    If($User.PasswordLastSet){
        $PasswordExpiryDate = (Get-Date ($User.PasswordLastSet)).AddDays(90)
    }
    Elseif($User.PasswordLastSet = $null){
        $PasswordExpiryDate = "NULL"
    }
    $UAC = DecodeUserAccountControl($User.userAccountControl)

    $Report += New-Object PSObject -Property ([ordered]@{
        'Username' = $User.SamAccountName
        'Name' = $User.Name
        'Description' = $User.Description
        'OU' = $UserOU
        'Domain' = 'vt.local'
        'Creation Date' = $User.Created
        'Password Last Set' = $User.PasswordLastSet
        'Password Expiration Date' = $PasswordExpiryDate
        'User Account Control' = $UAC
        'Last Logon' = $User.LastLogonDate
        'Account Enabled' = $User.Enabled
        'Password Not Required' = $User.PasswordNotRequired
        'Password Never Expires' = $User.PasswordNeverExpires
        'Password Cannot Change' = $User.CannotChangePassword
        'Account Locked Out' = $User.LockedOut
        'Account Expiration' = $User.AccountExpirationDate
    })
}
