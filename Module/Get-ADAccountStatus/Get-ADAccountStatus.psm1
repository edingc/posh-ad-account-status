<#
	.SYNOPSIS

	This Cmdlet returns account status for a given Active Directory account.
	
	.DESCRIPTION
	As a way to help troubleshoot, this cmdlet returns a brief overview about the status of a given Active Directory account. The information returned includes whether the account is enabled, expired or locked, when the password was last changed, and when the password is set to expire.

	.EXAMPLE
	
	Get-ADAccountStatus ceding
	
	Get-ADAccountStatus -Identity ceding
	
	.NOTES

	Requires Powershell v3 and Active Directory cmdlets.

#>

function Get-ADAccountStatus {

[CmdletBinding()]
PARAM (
	[Parameter(
		Mandatory = $True,
		ValueFromPipelineByPropertyName = $True,
		Position = 1)]
	[ValidateNotNullOrEmpty()]
	[string]
	$Identity
)

	Process {

		$AccountInfo = Get-ADUser -Identity $Identity -Properties DisplayName,Enabled,LockedOut,PasswordLastSet,PasswordExpired,PasswordExpired,msDS-UserPasswordExpiryTimeComputed

		# Need to define a variable for password expiry time because PowerShell doesn't like the .NET syntax
		# From http://blogs.technet.com/b/poshchap/archive/2014/02/21/get-a-list-of-ad-users-39-password-expiry-dates.aspx
		$PasswordExpiryTime = [datetime]::FromFileTime( $AccountInfo."msDS-UserPasswordExpiryTimeComputed" )
		
		$AccountObject = New-Object PSObject
		Add-Member -InputObject $AccountObject -MemberType NoteProperty -Name Account -Value $Identity
		Add-Member -InputObject $AccountObject -MemberType NoteProperty -Name DisplayName -Value $AccountInfo.DisplayName
		Add-Member -InputObject $AccountObject -MemberType NoteProperty -Name Enabled -Value $AccountInfo.Enabled
		Add-Member -InputObject $AccountObject -MemberType NoteProperty -Name LockedOut -Value $AccountInfo.LockedOut
		Add-Member -InputObject $AccountObject -MemberType NoteProperty -Name PasswordLastSet -Value $AccountInfo.PasswordLastSet
		Add-Member -InputObject $AccountObject -MemberType NoteProperty -Name PasswordExpired -Value $AccountInfo.PasswordExpired
		Add-Member -InputObject $AccountObject -MemberType NoteProperty -Name PasswordExpiryTime -Value $PasswordExpiryTime

		$AccountObject

	}

}

Export-ModuleMember -Function Get-ADAccountStatus