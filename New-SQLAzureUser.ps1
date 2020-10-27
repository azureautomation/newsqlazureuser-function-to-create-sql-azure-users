<# 
.SYNOPSIS  
   Creates User on SQL Azure database

.DESCRIPTION 
    This function requires a credential input of a user who has permissions 
    to create users (loginmanager role member)
    and will create a user for the database on the server entered

.PARAMETER Server 
        The Azure server hosting the database
 
.PARAMETER CredentialName 
    The name of the Azure Automation Credential Asset.
    This should be created using 
    http://azure.microsoft.com/blog/2014/08/27/azure-automation-authenticating-to-azure-using-azure-active-directory/  
 
.PARAMETER Database 
        The Azure Database 
 
.PARAMETER Cred 
        A credential object for a user who is a member of the loginmanager 
        role in the master database on the server

.PARAMETER User
        The name of the user
.PARAMETER Password
        The Users Password

.EXAMPLE 
    $cred = Get-Credential
    New-SQLAzureUser -server thebeardserver.database.windows.net -Database TheBeard `
     -cred $Cred -User AutoUser -Password Password01 -Role db_owner

    This example will create a user called AutoUser with a Password of Password01 on 
    thebeardserver.database.windows.net for the database TheBeard and make it a member 
    of the db_owner role
.OUTPUTS
    None
 
.NOTES 
    Name: New-SQLAzureUser
    Author: Rob Sewell 07/01/2015 sqldbawithabeard.com
    Requires: 
    Invoke-SQLCmd2
    Version History: 
#> 

function New-SQLAzureUser
{
param(
[String]$server,
[String]$Database,
[System.Management.Automation.PSCredential]$Cred,
[String]$User,
[String]$Password,
[String]$Role
 )

$UserQuery1 = @"
CREATE LOGIN [$User] WITH password='$Password';
"@
Invoke-Sqlcmd2 -Query $UserQuery1 -ServerInstance $server -Database master  -Credential $cred

$DBUserQuery1 = @"
CREATE USER [$User]FROM LOGIN [$User];
"@

Invoke-Sqlcmd2 -Query $DBUserQuery1 -ServerInstance $server -Database $Database  -Credential $cred


$DBUserQuery2= @"
EXEC sp_addrolemember $Role, [$User]
"@

Invoke-Sqlcmd2 -Query $DBUserQuery2 -ServerInstance $server -Database $Database  -Credential $cred
}