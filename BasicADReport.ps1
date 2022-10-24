#OnPremOnly
$Users = Get-ADUser -SearchBase "" -Filter "*" -Properties MemberOf, PasswordNeverExpires, PasswordLastSet, PasswordExpired, AccountExpirationDate, Enabled, LastLogonDate, EmailAddress, EmployeeID
$Export = @()

Foreach($User in $Users){
    $UserGroups = $null
    Foreach($Group in $User.MemberOf){
        $Group = (($Group -split "CN=")[1] -split ",OU=")[0]
        $UserGroups += "$Group; "
    }
    $Property = [ordered]@{
        "Name" = $User.Name
        "Username" = $User.SamAccountName
        "Employee ID" = $User.EmployeeID
        "Member Of" = $UserGroups
        "Email" = $User.EmailAddress
        "Password Never Expires" = $User.PasswordNeverExpires
        "Password Expired" = $User.PasswordExpired
        "Password Last Set" = $User.PasswordLastSet
        "Account Last Logon Date" = $User.LastLogonDate
        "Account Expiration Date (If set)" = $User.AccountExpirationDate
        "Account Enabled" = $User.Enabled
    } 
    $Object = New-Object PSObject -Property $Property
    $Export += $Object
}

$Export | Export-Csv "C:\Temp\UserReportDump.csv" -NoTypeInformation -NoClobber
