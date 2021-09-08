#list of hyper-v commands to verify you have the Hyper-V PS Moduel.
Get-Command -Module Hyper-v

#If the script fails, run the following. 
Set-ExecutionPolicy -ExecutionPolicy Unrestricted


$VM="SPA-UTIL01"
#Create VM
New-VM -Name $VM -Path "D:\HyperV\VirtualMachines" -Generation 1 -BootDevice CD -SwitchName "SPA Switch" 
New-VHD -Path "D:\HyperV\VirtualMachines\SPA-UTIL01\SPA-UTIL.vhdx" -SizeBytes 40GB -Dynamic 
Add-VMHardDiskDrive -VMName $VM -Path "D:\HyperV\VirtualMachines\SPA-UTIL01\SPA-UTIL.vhdx"
Set-VMDvdDrive -VMName $VM -ControllerNumber 1 -Path "D:\HyperV\VHDXs\20348.1.210507-1500.fe_release_SERVER_EVAL_x64FRE_en-us.iso"
#Set-VMMemory -VMName $VM -DynamicMemoryEnabled $true -StartupBytes 1024MB -MinimumByte 512
Set-VMProcessor -VMName $VM -Count 1 -CompatibilityForMigrationEnabled $true -Maximum 10 

#Start the Virtual Machine. 
Start-VM -Name $VM
