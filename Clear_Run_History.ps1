###########################################################################################################################
#	Clear_Run_History
#--------------------------------------------------------------------------------------------------------------------------
# Author: Steven Swanson
# Description:
#		Whenever this script is ran, it will delete the history of Run.
#		Programs, commands, scripts kept in history will be removed.
###########################################################################################################################
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
Function Get-Registry-Property-Or-Null {
	param(
		[Parameter(Position = 0, Mandatory = $true)]
        [String]$Key
	)
	return $( Get-Registry-Key-Or-Null $Key | Select-Object -ExpandProperty Property -EA SilentlyContinue)
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
#################################################################################################################################
#			Script Section
#################################################################################################################################

$Key="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU\"
Delete-Registry-Property -Key $Key -Property *