#This guide is for an environment that contains 3 server blades 

#PreReq | Use powershell 
# Windows roles/features
install-WindowsFeature "fs-data-deduplication","hyper-v","RSAT-clustering-powershell","Failover-clustering","Data-Center-Bridging" -IncludeManagementTools

#Disable firewall for all profiles
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

#Configuring your host. It is recommended to use the "Sconfig" command in powershell to do basic configurations(Change host name, config host management NIC
#(Use NIC1 on the ASM) make sure to assign DNS addresses to this NIC, enable remote management, enable response to ping). Once this is complete, and you've 
#doubled checked your configuration, add your host to the domain.

#Set management NIC vlan ID (It is recommended to use a 10GB NIC)
Set-NetAdapter NIC1 -VlanID ^VLAN ID^

#Create VMswitch with embedded teaming and MGMT VMNIC 
  #ASM
   New-VMSwitch -Name SwitchEmbeddedTeam -EnableEmbeddedTeaming $true -AllowManagementOS $false -NetAdapterName "NIC3","NIC4"
  #LSM
   New-VMSwitch -Name SwitchEmbeddedTeam -EnableEmbeddedTeaming $true -AllowManagementOS $false -NetAdapterName "Ethernet","Ethernet 4"

#Setup for storage vmnic
Add-VMNetworkAdapter -ManagementOS -Name Storage_1 -SwitchName SwitchEmbeddedTeam
Add-VMNetworkAdapter -ManagementOS -Name Storage_2 -SwitchName SwitchEmbeddedTeam

#vmnic for ASM
Get-VMNetworkAdapter -VMNetworkAdapterName "Storage_1" -ManagementOS  | Set-VMNetworkAdapterTeamMapping -PhysicalNetAdapterName "NIC3"
Get-VMNetworkAdapter -VMNetworkAdapterName "Storage_2" -ManagementOS  | Set-VMNetworkAdapterTeamMapping -PhysicalNetAdapterName "NIC4"
#Setup NIC VMQ for the ASM
Get-NetAdapterVmq "NIC2" | Set-NetAdapterVmq -BaseProcessorGroup 0 -BaseProcessorNumber 2 -MaxProcessors 35
Get-NetAdapterVmq "NIC3" | Set-NetAdapterVmq -BaseProcessorGroup 1 -BaseProcessorNumber 2 -MaxProcessors 35

#vmnic for LSM
Get-VMNetworkAdapter -VMNetworkAdapterName "Storage_1" -ManagementOS  | Set-VMNetworkAdapterTeamMapping -PhysicalNetAdapterName "Ethernet"
Get-VMNetworkAdapter -VMNetworkAdapterName "Storage_2" -ManagementOS  | Set-VMNetworkAdapterTeamMapping -PhysicalNetAdapterName "Ethernet 4"
#Setup NIC VMQ 

#Test the host configurations for a cluster. Either use this command or the failover cluster manager GUI
test-cluster $Nodes  -Include "storage Spaces direct","inventory","network","system configuration" -ReportName C:\clusterreport -verbose
#review the cluster report by opening it up in a web browser

#Create A Cluster, and assign the cluster an IP address
New-Cluster -Name DIV^^CLUSTER -Node DIV^^HOST^^^,DIV^^HOST^^^ -NoStorage -StaticAddress "***.***.***.***" -verbose

#Enable Storage Spaces Direct
Enable-ClusterS2D -verbose

#Create New Volumes 
New-Volume -StoragePool (Get-StoragePool s2d*) -FileSystem CSVFS_ReFS -Size 4TB -FriendlyName DIV**-S2D-CSV

#Enable VMMigration
$Nodes = "DIV^^HOST^^^","DIV^^HOST^^^","DIV^^HOST^^^"

$hostnames = $nodes|ForEach-Object{$_+"$"}   

Enable-VMMigration $nodes

#Enable Data Deduplication on the cluster storage
Enable-DedupVolume -Volume C:\ClusterStorage\DIV^^-S2D-CSV\ -UsageType HyperV

#Set VM Load Balancing
(Get-Cluster DIV**Cluster).AutoBalancerLevel = 2
(Get-Cluster DIV**Cluster).AutoBalancerMode = 2

#Change Default Location on Cluster
Set-VMHost $Nodes -VirtualHardDiskPath c:\ClusterStorage\DIV**-S2d-CSV\VHDX -VirtualMachinePath c:\ClusterStorage\DIV**-S2d-CSV\VMCX

#Set nodes to use Kerberos and SMB.
Set-VMHost $nodes -VirtualMachineMigrationAuthenticationType Kerberos -VirtualMachineMigrationPerformanceOption SMB 
$nodes|ForEach-Object{Set-ADComputer $_ -PrincipalsAllowedToDelegateToAccount $hostnames}
