Import-Module ./lib_sec_policy.psm1

function list_user_local_login(){
	return Get-AccountsWithUserRight SeInteractiveLogonRight
}
function add_user_local_login(){
	param(
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$User
	)
	process {
		Grant-UserRight $User SeInteractiveLogonRight
	}
}
function remove_user_local_login(){
	param(
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$User
	)
	process {
		Revoke-UserRight $User SeInteractiveLogonRight
	}
}
function list_user_remote_login(){
	return $(Get-AccountsWithUserRight SeRemoteInteractiveLogonRight)
}
function add_user_remote_login(){
	param(
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$User
	)
	process {
		Grant-UserRight $User SeRemoteInteractiveLogonRight
	}
}
function remove_user_remote_login(){
	param(
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$User
	)
	process {
		Revoke-UserRight $User SeRemoteInteractiveLogonRight
	}
}

function clear_login_rights(){
	process {
		$users = list_user_local_login
		foreach ($user in $users.Account) {
			if ($user -ne "BUILTIN\Administrators"){
				remove_user_local_login $user
				remove_user_remote_login $user
			}
		}
		add_user_local_login "BUILTIN\Administrators"
		add_user_remote_login "BUILTIN\Administrators"
	}
}