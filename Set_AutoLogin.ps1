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
#==========================================================================================================================
#	Test-Registry-Key
#--------------------------------------------------------------------------------------------------------------------------
#	This allows testing of a key path within the system Registry, function will return True if the key exists.
#
#	Example: Test-Registry-Key -Key 'HKLM\SOFTWARE\Microsoft\Windows'
#==========================================================================================================================
Function Test-Registry-Key {
	param(
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Key
	)
	process {
		return ((Get-Registry-Key-Or-Null $Key) -ne $null)
	}
}

#=============================================================================================================================
#	Test-Registry-Property
#-----------------------------------------------------------------------------------------------------------------------------
#	This allows testing of a key's property within the system Registry, function will return True if the Property exists.
#
#	Example: Test-Registry-Key -Key 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Property 'LastUsedUsername'
#=============================================================================================================================
Function Test-Registry-Property {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Key
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Property
	)
	
	process {
		return ((Get-Registry-Property-Or-Null $Key $Property) -ne $null)
	}
}

#=============================================================================================================================
#	Test-Registry-Value
#-----------------------------------------------------------------------------------------------------------------------------
#	This allows testing of a key's property value within the system Registry, function will return True if the value is the
#		same as the one provided. exists.
#
#	Example: Test-Registry-Key -Key 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' \
#					-Property 'LastUsedUsername' -Value 'shared'
#=============================================================================================================================
Function Test-Registry-Value {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Key
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Property
		,
		[Parameter(Position = 2, Mandatory = $true)]
        [String]$Value
	)
	
	process {
		return ((Get-Registry-Value-Or-Null $Key $Property) -eq $Value)
	}
}
#==========================================================================================================================
#	Set_Registry_Path
#--------------------------------------------------------------------------------------------------------------------------
#	This is to be used by various functions to ensure that Path is correct
#
#	Example: Get-Registry-Key -Key 'HKLM\SOFTWARE\Microsoft\Windows'
#==========================================================================================================================
Function Set_Registry_Path {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Key
	)
	if (! $Key.StartsWith("Registry::") ){
		return "Registry::"+$Key
	}
	return $Key
}
#==========================================================================================================================
#	Get-Registry-Key-Or-Null
#--------------------------------------------------------------------------------------------------------------------------
#	This will retrieve the Registry Key at given path, if it exists. If it does not exist, will return $null
#
#	Example: Get-Registry-Key -Key 'HKLM\SOFTWARE\Microsoft\Windows'
#==========================================================================================================================
Function Get-Registry-Key-Or-Null {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Key
	)
	return $(Get-Item -Path (Set_Registry_Path $Key) -EA SilentlyContinue)
}
#==========================================================================================================================
#	Get-Registry-Key-Properties-Or-Null
#--------------------------------------------------------------------------------------------------------------------------
#	This will give a list of Properties available for given Key, if it exists.
#
#	Example: Get-Registry-Key-Properties-Or-Null -Key 'HKLM\SOFTWARE\Microsoft\Windows'
#==========================================================================================================================
Function Get-Registry-Key-Properties-Or-Null {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Key
	)
	return $( Get-Registry-Key-Or-Null $Key | Select-Object -ExpandProperty Property -EA SilentlyContinue)
}
#==========================================================================================================================
#	Get-Registry-Property-Or-Null
#--------------------------------------------------------------------------------------------------------------------------
#	This will retrieve the Registry Property at given path, if it exists. If it does not exist, will return $null
#
#	Example: Get-Registry-Key-Properties-Or-Null -Key 'HKLM\SOFTWARE\Microsoft\Windows'
#==========================================================================================================================
Function Get-Registry-Property-Or-Null {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Key
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Property
	)
	
	process {
		return $(Get-ItemProperty -Path (Set_Registry_Path $Key) -Name $Property -EA SilentlyContinue)
	}
}
#==========================================================================================================================
#	List-Registry-Properties
#--------------------------------------------------------------------------------------------------------------------------
#	Get a list of all properties located at given Key
#
#	Example: List-Registry-Properties -Key 'HKLM\SOFTWARE\Microsoft\Windows'
#==========================================================================================================================
Function List-Registry-Properties {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Key
	)
	process {
		return Get-Item $Key | Select-Object -ExpandProperty property
	}
}
#==========================================================================================================================
#	Get-Registry-Property-Type
#--------------------------------------------------------------------------------------------------------------------------
#	This will get the Value Type of given Property. Types of values below:
#
#	Types:
#	- String
#	- Binary
#	- DWORD (32-bit) value
#	- QWORD (64-bit) value
#	- Multi-String
#	- Expandable String
#
#	Example: Get-Registry-Key-Properties-Or-Null -Key 'HKLM\SOFTWARE\Microsoft\Windows'
#==========================================================================================================================
Function Get-Registry-Property-Type {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Key
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Property
	)
	process {
		$reg_key = Get-Registry-Key-Or-Null $Key 
		if ($reg_key -ne $null){
			return $reg_key.GetValueKind($Property)
		}
		return $null
	}
}
#=============================================================================================================================
#	Get-Registry-Value-Or-Null
#-----------------------------------------------------------------------------------------------------------------------------
#	This will retrieve the value of the Registry Property at given path, if it exists. If it does not exist, will return $null
#
#	Example: Test-Registry-Key -Key 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' \
#					-Property 'LastUsedUsername' -Value 'shared'
#=============================================================================================================================
Function Get-Registry-Value-Or-Null {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Key
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Property
	)
	
	process {
		$prop = Get-Registry-Property-Or-Null $Key $Property
		if ($prop -ne $null) {
			return $($prop).$Property
		}
		return $null
	}
}
#
#	Creation Section
#

#==========================================================================================================================
#	Create-Registry-Key
#--------------------------------------------------------------------------------------------------------------------------
#	This will Create a Registry Key at given Path with Given Name. If the entire path does not exist, it will 
#		create the missing keys.
#
#	Example: Get-Registry-Key -Path 'HKLM\SOFTWARE\Microsoft\Windows NT' -Name 'NewKey'
#==========================================================================================================================
Function Create-Registry-Key {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Path
		,
        [Parameter(Position = 1, Mandatory = $false)]
        [String]$Name
	)
	if ($Path.EndsWith('\')){
		$Path = $Path.TrimEnd('\')
	}
	if (-not(Test-Registry-Key "$Path")){
		$path_list = $Path.split('\')
		Create-Registry-Key ($path_list[0..($path_list.Length-2)] -join "\") ($path_list[($path_list.Length-1)])
	}
	if (-not(Test-Registry-Key "$Path\$Name")) {
		if (New-Item -Path (Set_Registry_Path $Path) -Name $Name ){
			return Get-Registry-Key-Or-Null "$Path\$Name"
		}
	}
	return $null
}
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

#==========================================================================================================================
#	Delete-Registry-Key
#--------------------------------------------------------------------------------------------------------------------------
#	This will delete the Registry Key at given path.
#
#	Example: Delete-Registry-Key -Key 'HKLM\SOFTWARE\Microsoft\Windows'
#==========================================================================================================================
Function Delete-Registry-Key {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Key
		,
        [Parameter(Position = 1, Mandatory = $false)]
        [Switch]$Recurse
	)
	if ($Recurse.IsPresent){
		(Remove-Item -Path (Set_Registry_Path $Key) -Recurse -EA SilentlyContinue)
		if (Test-Registry-Key "$Key"){
			return $false
		}
	}
	else{
		(Remove-Item -Path (Set_Registry_Path $Key) -EA SilentlyContinue)
		if (Test-Registry-Key "$Key"){
			return $false
		}
	}
	return $true
}
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
		(Remove-ItemProperty -Path $Key -Name $Property -EA SilentlyContinue)
		if ((Test-Registry-Property $Key $Property)){
			return $false
		}
		return $true
	}
}

#
#	Modify Section
#

#==========================================================================================================================
#	Rename-Registry-Key
#--------------------------------------------------------------------------------------------------------------------------
#	This will rename the Registry Key at given path.
#
#	Example: Rename-Registry-Key -Key 'HKLM\SOFTWARE\Microsoft\Windows' -NewName "NotWindows"
#==========================================================================================================================
Function Rename-Registry-Key {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Path
		,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$NewName
	)
	if (Test-Registry-Key "$Path\$OldName"){
		if (Rename-Item -Path (Set_Registry_Path $Path) -NewName $Newname -PassThru) {
			return $true
		}
	}
	return $false
}
#=============================================================================================================================
#	Rename-Registry-Property
#-----------------------------------------------------------------------------------------------------------------------------
#	This will rename the Registry Property at given path.
#
#	Example: Rename-Registry-Key -Key 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name "LastUsedUsername" -NewName "LastUsedUsername2"
#=============================================================================================================================
Function Rename-Registry-Property {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Path
		,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Name
		,
        [Parameter(Position = 2, Mandatory = $true)]
        [String]$NewName
	)
	
	process {
		if ((Test-Registry-Property (Set_Registry_Path "$Path") $Name)){
			Rename-ItemProperty -Path (Set_Registry_Path $Path) -Name $Name -NewName $NewName
			if (Test-Registry-Property (Set_Registry_Path "$Path") $NewName){
				return $true
			}
		}
		return $false
	}
}
#=============================================================================================================================
#	Edit-Registry-Property
#-----------------------------------------------------------------------------------------------------------------------------
#	This will change the value of given property with given new value.
#
#	Example: Test-Registry-Key -Key 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' \
#					-Property 'LastUsedUsername' -Value 'shared'
#=============================================================================================================================
Function Edit-Registry-Property {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Path
		,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Property
		,
        [Parameter(Position = 2, Mandatory = $true)]
        [String]$Value
	)
	
	process {
		if ((Test-Registry-Property (Set_Registry_Path "$Path") $Property)){
			Set-ItemProperty -Path (Set_Registry_Path $Path) -Name $Property -Value $Value
			if (Test-Registry-Value -Key (Set_Registry_Path $Path) -Property $Property -Value $Value){
				return $true
			}
		}
		return $false
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