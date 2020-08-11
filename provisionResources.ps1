# TODO: set variables
$studentName = "Daniel"

$rgName = "${studentName}-events-aadb2c-rg"

$vmName = "${studentName}-events-aadb2c-vm"

$vmSize = "Standard_B2s"

$vmImage = "$(az vm image list --query "[? contains(urn, 'Ubuntu')] | [0].urn")"

$vmAdminUsername = "student"
$vmAdminPassword='LaunchCode-@zure1'

	#KV INFO
$kvName = "$studentName-lc0820-ps-kv"
$kvSecretName = "ConnectionStrings--Default"
$kvSecretValue = "server=localhost;port=3306;database=coding_events;user=coding_events;password=launchcode"

az configure --default location=eastus

	# TODO: provision RG
az group create -n "$rgName"

az configure --default group=$rgName


	# TODO: provision VM
az vm create -n $vmName --size $vmSize --image $vmImage --admin-username $vmAdminUsername --admin-password $vmAdminPassword --authentication-type password --assign-identity | Set-Content vm.json
az configure --default vm=$vmName

$vm = Get-Content .\vm.json | ConvertFrom-Json
	

	# TODO: capture the VM systemAssignedIdentity
$vmId=$vm.identity.systemAssignedIdentity


	# TODO: open vm port 443
az vm open-port --port 443


	# provision KV
az keyvault create -n $kvName --enable-soft-delete false --enabled-for-deployment true

	# TODO: create KV secret (database connection string)
az keyvault secret set --vault-name $kvName --description 'connection string' --name $kvSecretName --value $kvSecretValue


	# TODO: set KV access-policy (using the vm ``systemAssignedIdentity``)

az vm run-command invoke --command-id RunShellScript --scripts @vm-configuration-scripts/1configure-vm.sh

az vm run-command invoke --command-id RunShellScript --scripts @vm-configuration-scripts/2configure-ssl.sh

az vm run-command invoke --command-id RunShellScript --scripts @deliver-deploy.sh


	# TODO: print VM public IP address to STDOUT or save it as a file
echo "VM available at $vmIp"

