####################################################
## All VM Report Script (vCenter reports) - V 5.0 ##
####################################################
###########################################################################
# .\AllVMReport.ps1                                                       #
# V1 - 11/08/2015     					      	          #
# V2 - 27/10/2016                                                         #
# V3 - 05/05/2017     					      	          #
# V4 - 11/02/2018     					      	          #
# V5 - 31/05/2019     					      	          #
# Script reads the list of vCenter Servers from "./vCenterList.csv" file  #
###########################################################################

# Enable below line if you want to specity user credential for vCenter, 
#without changing this script is ready to be setup as a scheduled task. 
#Just makesure the service account you are using to run the task has read only rights on vCenters. 
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#$Cred = Get-Credential
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

foreach ($VCServer in get-content ./vCenterList.txt) {

# Enable below line if you want to specity user credential for vCenter, 
# and disable the next one. 
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#$Connection = Connect-VIServer $VCServer -Credential $Cred -WarningAction SilentlyContinue
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
$Connect = Connect-VIServer $VCServer -WarningAction SilentlyContinue
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If ($Connect){

Write-Host "Connected to vCenter" $VCServer

$AllVMReport = New-Object System.Collections.ArrayList
$VMS = Get-Cluster | Get-VM | Sort-Object -Property Name

    ForEach ($VM in $VMS) {
      
      $advview = get-view -viewtype virtualmachine -filter @{'name'=$VM.Name}
      If ($advview) {
      $CPUInfo = "Core:" + $advview.Config.Hardware.NumCPU + " Sockets:" + $advview.Config.Hardware.NumCoresPerSocket
      } 
      Else {
      $CPUInfo = "Err"
      }

      # REF:- https://packages.vmware.com/tools/versions  
      Switch ($VM.Guest.ExtensionData.ToolsVersion) {
        10250 {$ToolVers = "Outdated 10250"}
        10241 {$ToolVers = "Outdated 10241"}
        10278 {$ToolVers = "Outdated 10278"}
	10279 {$ToolVers = "10.1.7"}
	10277 {$ToolVers = "10.1.5"}
	10272 {$ToolVers = "10.1.0"}
	10252 {$ToolVers = "10.0.12"}
	10249 {$ToolVers = "10.0.9"}
	10249 {$ToolVers = "10.0.9"}
	10248 {$ToolVers = "10.0.8"}
	10246 {$ToolVers = "10.0.6"}
	10245 {$ToolVers = "10.0.5"}
	10240 {$ToolVers = "10.0.0"}
	9541 {$ToolVers = "9.10.5"}
	9537 {$ToolVers = "9.10.1"}
	9536 {$ToolVers = "9.10.0"}
	9359 {$ToolVers = "9.4.15"}
	9356 {$ToolVers = "9.4.12"}
	9355 {$ToolVers = "9.4.11"}
	9354 {$ToolVers = "9.4.10"}
	9350 {$ToolVers = "9.4.6"}
        9349 {$ToolVers = "9.4.5"}
	9344 {$ToolVers = "9.4.0"}
	9233 {$ToolVers = "9.0.17"}
	9232 {$ToolVers = "9.0.16"}
	9231 {$ToolVers = "9.0.15"}
	9229 {$ToolVers = "9.0.13"}
	9228 {$ToolVers = "9.0.12"}
	9227 {$ToolVers = "9.0.11"}
	9226 {$ToolVers = "9.0.10"}
	9221 {$ToolVers = "9.0.5"}
	9217 {$ToolVers = "9.0.1"}
	9216 {$ToolVers = "9.0.0"}
	8401 {$ToolVers = "8.6.17"}
	8400 {$ToolVers = "8.6.16"}
	8399 {$ToolVers = "8.6.15"}
	8398 {$ToolVers = "8.6.14"}
	8397 {$ToolVers = "8.6.13"}
	8396 {$ToolVers = "8.6.12"}
	8395 {$ToolVers = "8.6.11"}
	8394 {$ToolVers = "8.6.10"}
	8389 {$ToolVers = "8.6.5"}
	8384 {$ToolVers = "8.6.0"}
	8307 {$ToolVers = "8.3.19"}
	8306 {$ToolVers = "8.3.18"}
	8305 {$ToolVers = "8.3.17"}
	8300 {$ToolVers = "8.3.12"}
	8295 {$ToolVers = "8.3.7"}
	8290 {$ToolVers = "8.3.2"}
	8199 {$ToolVers = "8.0.7"}
	8198 {$ToolVers = "8.0.6"}
	8197 {$ToolVers = "8.0.5"}
	8196 {$ToolVers = "8.0.4"}
	8196 {$ToolVers = "8.0.4"}
	8195 {$ToolVers = "8.0.3"}
	8194 {$ToolVers = "8.0.2"}
	8192 {$ToolVers = "8.0.0"}
	7304 {$ToolVers = "7.4.8"}
	7303 {$ToolVers = "7.4.7"}
	7302 {$ToolVers = "7.4.6"}
   	0   {$ToolVers = "Not installed"}
   	2147483647 {$ToolVers = "3rd party-guest managed-: " + $VM.Guest.ExtensionData.ToolsVersion}
   	default {$ToolVers = "Unknown / PoweredOff"}
      }  
      
      $tempval = New-Object System.Object
      $tempval | Add-Member -MemberType NoteProperty -Name "VMName" -Value $VM.Name
      $tempval | Add-Member -MemberType NoteProperty -Name "DNSName" -Value $VM.ExtensionData.Guest.Hostname
      $tempval | Add-Member -MemberType NoteProperty -Name "PrimaryIP" -Value $VM.Guest.IPAddress[0]
      $tempval | Add-Member -MemberType NoteProperty -Name "PowerState" -Value $VM.PowerState
      $tempval | Add-Member -MemberType NoteProperty -Name "vCenter" -Value $VCServer
      $tempval | Add-Member -MemberType NoteProperty -Name "DataCenter" -Value ($VM | Get-Datacenter).name
      $tempval | Add-Member -MemberType NoteProperty -Name "Cluster" -Value ($VM | Get-Cluster).name
      $tempval | Add-Member -MemberType NoteProperty -Name "ESXiHost" -Value $VM.VMHost.name
      $tempval | Add-Member -MemberType NoteProperty -Name "GuestOS" -Value $VM.Guest.OSFullName
      $tempval | Add-Member -MemberType NoteProperty -Name "CPUInfo" -Value $CPUInfo
      $tempval | Add-Member -MemberType NoteProperty -Name "MemoryGB" -Value $VM.MemoryGB
      $tempval | Add-Member -MemberType NoteProperty -Name "VMHWVersion" -Value $VM.Version
      $tempval | Add-Member -MemberType NoteProperty -Name "VMID" -Value $VM.ID
      $tempval | Add-Member -MemberType NoteProperty -Name "VMToolVersion" -Value $ToolVers
      $tempval | Add-Member -MemberType NoteProperty -Name "VMToolStatus" -Value $VM.Guest.ExtensionData.ToolsStatus
      $tempval | Add-Member -MemberType NoteProperty -Name "VMToolGuest" -Value $VM.Guest.ExtensionData.ToolsRunningStatus
      $HDDFiles = ((($VM | Get-HardDisk).Filename | fw -AutoSize) | Out-String).trim()
      $tempval | Add-Member -MemberType NoteProperty -Name "VMDKDisks" -Value $HDDFiles
      $AllVMReport.Add($tempval) | Out-Null
    }
}
$AllVMReport | Export-csv ".\Report\AllVMReport.csv" -NoTypeInformation -append
Disconnect-VIServer -Server $VCServer -Confirm:$false
}
