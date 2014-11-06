#==============================================================================================
# XAML Code - Imported from Visual Studio Express 2013 WPF Application
#==============================================================================================

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Active Directory Account Status" Height="250" Width="370" ResizeMode="NoResize" WindowStartupLocation="CenterScreen">
    <Grid>
        <TextBox Name="Username" HorizontalAlignment="Left" Height="23" Margin="100,10,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="160" ToolTip="AD Username to Query"/>
        <TextBox Name="AccountStatus" HorizontalAlignment="Left" Height="164" Margin="10,40,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="334" FontSize="14" IsEnabled="False" RenderTransformOrigin="0.725,0.521"/>
        <Label Content="AD Username" HorizontalAlignment="Left" Margin="10,7,10,10" VerticalAlignment="Top" Width="100"/>
        <Button Name="SearchButton" Content="Search" IsDefault="True" HorizontalAlignment="Left" Margin="269,10,10,10" VerticalAlignment="Top" Width="75"/>
    </Grid>
</Window>
'@

#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}

#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================

$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}

#===========================================================================
# Add events to Form Objects
#===========================================================================

$SearchButton.Add_Click({

	If ( $Username.text -eq "" ) {
		
		$AccountStatus.text = "No username entered."
		
	} Else {
	
		$AccountInfo = Get-ADUser -Identity $Username.text -Properties DisplayName,Enabled,LockedOut,PasswordLastSet,PasswordExpired,PasswordExpired,msDS-UserPasswordExpiryTimeComputed
		
		If ( $AccountInfo ) {
		
			$AccountStatus.IsEnabled = $True

			$sAMaccountName = $Username.text
			$DisplayName = $AccountInfo.DisplayName
			$Enabled = $AccountInfo.Enabled
			$LockedOut = $AccountInfo.LockedOut
			$PasswordLastSet = $AccountInfo.PasswordLastSet
			$PasswordExpired = $AccountInfo.PasswordExpired
			# Need to define a variable for password expiry time because PowerShell doesn't like the .NET syntax
			# From http://blogs.technet.com/b/poshchap/archive/2014/02/21/get-a-list-of-ad-users-39-password-expiry-dates.aspx
			$PasswordExpiryTime = [datetime]::FromFileTime( $AccountInfo."msDS-UserPasswordExpiryTimeComputed" )
		
			$UserDisplay = "Account: $sAMaccountName`r`nDisplay Name: $DisplayName`r`nEnabled: $Enabled`r`nLocked Out: $LockedOut`r`nPassword Last Set: $PasswordLastSet`r`nPassword Expired: $PasswordExpired`r`nPassword Expiry Time: $PasswordExpiryTime"
	
			$AccountStatus.Text = $UserDisplay
		
		} Else {
		
			$AccountStatus.Text = "No accounts found matching the input value."
		
		}
	
	}

})

#===========================================================================
# Shows the form
#===========================================================================
$Form.ShowDialog() | out-null