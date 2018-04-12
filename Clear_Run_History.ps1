###########################################################################################################################
#	Clear_Run_History
#--------------------------------------------------------------------------------------------------------------------------
# Author: Steven Swanson
# Description:
#		Whenever this script is ran, it will delete the history of Run.
#		Programs, commands, scripts kept in history will be removed.
###########################################################################################################################

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