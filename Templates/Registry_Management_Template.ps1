###########################################################################################################################
#	Registry Template
#--------------------------------------------------------------------------------------------------------------------------
# Author: Steven Swanson
# Description:
#		This powershell script is to be used as a template to create scripts
#		This Template contains the needed functions for the manipulation of the Registry
#		This will need to be ran as an Administrator to make changes to majority of Registry keys.
###########################################################################################################################

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
		(Remove-ItemProperty -Path $Key -Name $Property)
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

Function Test-Registry-Template {
	write-host $( Test-Registry-Key $Path )
	write-host $( Test-Registry-Property $Path $Name)
	write-host $( Test-Registry-Value $Path $Name $Value)
	write-host $( Get-Registry-Key-Or-Null $Path)
	write-host $( Get-Registry-Key-Properties-Or-Null $Path)
	write-host $( Get-Registry-Property-Or-Null $Path $Name)
	write-host $( Get-Registry-Property-Type $Path $Name)
	write-host $( Get-Registry-Value-Or-Null $Path $Name)
	write-host $( Create-Registry-Key "$Path\" "test")
	write-host $( Create-Registry-Property "$Path\test\test\test" $Name 'String' $Value)
	read-host "Press Enter to edit"
	write-host $( Rename-Registry-Key -Path "$Path\test" -NewName "Test2")
	write-Host $( Edit-Registry-Property -Path "$Path\Test2\test\test" -Name $Name -Value $Value"2")
	write-Host $( Rename-Registry-Property -Path "$Path\Test2\test\test" -Name $Name -NewName $Name"2")
	Read-Host "Press Return to delete Test Registries"
	write-host $( Delete-Registry-Property "$Path\Test2\test\test" $Name)
	write-host $( Delete-Registry-Key "$Path\Test2\test\test")
	write-host $( Delete-Registry-Key "$Path\Test2" -recurse)
	read-host
}
