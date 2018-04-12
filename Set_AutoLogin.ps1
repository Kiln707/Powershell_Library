###########################################################################################################################
#	Set_AutoLogin
#--------------------------------------------------------------------------------------------------------------------------
# Author: Steven Swanson
# Description:
#		Configure the computer to automatically log in as the user@domain
###########################################################################################################################

param(
	[string]$User,
	[string]$Domain,
	[string]$Password
)

##############################
#	Library Section
##############################

#=============================================================================================================================
#	Create-Registry-Property
#-----------------------------------------------------------------------------------------------------------------------------
#	This will create a registry property with given name at key location with type/value given. 
#	Types:
#	- String
#	- Binary
#	- DWORD (32-bit) value
#	- QWORD (64-bit) value
#	- Multi-String
#	- Expandable String
#
#	Example: Test-Registry-Key -Key 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' \
#					-Property 'LastUsedUsername' -Type -Value 'shared'
#=============================================================================================================================
Function Create-Registry-Property {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Key
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Property
		,
		[Parameter(Position = 2, Mandatory = $true)]
        [String]$Type
		,
		[Parameter(Position = 3, Mandatory = $true)]
        [String]$Value
	)
	
	process {
		if (-not(Test-Registry-Key "$Key")) {
			Create-Registry-Key $Key
		}
		if (-not (Test-Registry-Property $Key $Property)){
			if (New-ItemProperty -Path (Set_Registry_Path $Key) -Name $Property -Type $Type -Value $Value){
				
				return Get-Registry-Property-Or-Null $Key $Property
			}
		}
		return $null
	}
}

#
#	Delete Section
#

#=============================================================================================================================
#	Delete-Registry-Property
#-----------------------------------------------------------------------------------------------------------------------------
#	This will Delete the property at given path
#
#	Example: Delete-Registry-Key -Key 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Property 'LastUsedUsername'
#=============================================================================================================================
Function Delete-Registry-Property {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Key
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Property
	)
	
	process {
		(Remove-ItemProperty -Path (Set_Registry_Path $Key) -Name $Property -EA SilentlyContinue)
		if ((Test-Registry-Property $Key $Property)){
			return $false
		}
		return $true
	}
}


#######################################################################################################################################
#	Start Script
#######################################################################################################################################

#Function is called when a form will need to be created. This should make script faster when using commandline structure and not GUI
Function Show-GUI {
	# Creation of Form Object
	Add-Type -Assembly 'System.Windows.Forms'
	$form = New-Object Windows.Forms.Form
	$form.text = "Set Automatic Login"
	$form.Size = New-Object System.Drawing.Size(250,240)
	$form.MinimizeBox = $False
	$form.MaximizeBox = $False
	$form.WindowState = "Normal"
	$form.SizeGripStyle = "Hide"
	$form.ShowInTaskbar = $False
	$form.StartPosition = "CenterScreen"
	$form.FormBorderStyle = 'Fixed3D'
	#Username Section of form
	$UsernameInstructions = New-Object System.Windows.Forms.label
	$UsernameInstructions.text = "Please enter Username."
	$UsernameInstructions.AutoSize = $True
	$UsernameInstructions.Top  = 10
	$UsernameInstructions.Left = 10
	$UsernameTextbox = New-Object Windows.Forms.TextBox
	$UsernameTextbox.Top  = 30
	$UsernameTextbox.Left = 10
	#Domain Section of form
	$DomainInstructions = New-Object System.Windows.Forms.label
	$DomainInstructions.text = "Please enter Domain of User."
	$DomainInstructions.AutoSize = $True
	$DomainInstructions.Top  = 60
	$DomainInstructions.Left = 10
	$DomainTextbox = New-Object Windows.Forms.TextBox
	$DomainTextbox.Top  = 80
	$DomainTextbox.Left = 10
	#Password Section
	$PasswordInstructions = New-Object System.Windows.Forms.label
	$PasswordInstructions.text = "Please enter password for Credential."
	$PasswordInstructions.AutoSize = $True
	$PasswordInstructions.Top  = 110
	$PasswordInstructions.Left = 10
	$passwordTextbox = New-Object Windows.Forms.MaskedTextBox
	$passwordTextbox.PasswordChar = '*'
	$passwordTextbox.Top  = 130
	$passwordTextbox.Left = 10
	# Form Validation Function
	Function Validate {
		
	}
	#Okay Button
	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(30,160)
	$OKButton.Size = New-Object System.Drawing.Size(75,23)
	$OKButton.Text = 'OK'
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	# Add Validation Control
	$ErrorProvider = New-Object System.Windows.Forms.ErrorProvider
	#Add Controls to Form
	$form.Controls.Add($UsernameInstructions)
	$form.Controls.Add($UsernameTextbox)
	$form.Controls.Add($DomainInstructions)
	$form.Controls.Add($DomainTextbox)
	$form.Controls.Add($PasswordInstructions)
	$form.Controls.Add($passwordTextbox)
	$form.Controls.Add($OKButton)
	
	while ($True) {
		if ($form.ShowDialog() -eq 'CANCEL'){
			return $null
		} else {
			$ErrorProvider.Clear()
			if ([String]::IsNullorEmpty($UsernameTextbox.Text) -or [String]::IsNullorEmpty($DomainTextbox.Text) ){
				if ([String]::IsNullorEmpty($UsernameTextbox.Text)){
					$ErrorProvider.SetError($UsernameTextbox, "Please enter a Username!")
				}
				if ([String]::IsNullorEmpty($DomainTextbox.Text)) {
					$ErrorProvider.SetError($DomainTextbox, "Please enter a Domain!")
				}
			} else {
				break
			}
		}
	}
	return $UsernameTextbox.Text, $DomainTextbox.Text, $passwordTextbox.Text
}

if( ($user -eq "") -and ($domain -eq "") ){
	$values = Show-GUI
	if ($values -ne $null) {
		$User = $values[0]
		$Domain = $values[1]
		$Password = $values[2]
		if ($password -eq "") { 
			[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
			$empty=[Microsoft.VisualBasic.Interaction]::MsgBox("Do you want to use an empty password? Press No to quit", "YesNo,SystemModal,Information", "Use Empty Password")
			if ($empty -eq "No") { exit 1 }
		}
	} else { exit 1 }
}
elseif( ($user -eq "") -or ($domain -eq "") ){
		$scriptname = $MyInvocation.MyCommand.Name
		Write-Host "Please see correct usage: $scriptname -user [USERNAME] -domain [DOMAINNAME] <-password [password]>"
		exit 1;
}
#Set non user variables
$HKLM="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$regType="String"
$domain=$domain.toUpper()

$AutoLogin = 'AutoAdminLogon'
$ForceLogin = 'ForceAutoLogon'
$DefUser = 'DefaultUserName'
$DefDomain = 'DefaultDomainName'
$DefPass = 'DefaultPassword'

#Delete old registry properties, in case they exist
Delete-Registry-Property $HKLM $AutoLogin 
Delete-Registry-Property $HKLM $ForceLogin
Delete-Registry-Property $HKLM $DefUser
Delete-Registry-Property $HKLM $DefDomain
Delete-Registry-Property $HKLM $DefPass

Create-Registry-Property $HKLM $AutoLogin $regType 1
Create-Registry-Property $HKLM $ForceLogin $regType 1
Create-Registry-Property $HKLM $DefUser $regType $User
Create-Registry-Property $HKLM $DefDomain $regType $Domain
Create-Registry-Property $HKLM $DefPass $regType $Password