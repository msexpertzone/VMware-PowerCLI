######################################################
## All ESXi Report Script (vCenter reports) - V 1.0 ##
######################################################
###########################################################################
# .\AllESXiReport.ps1                                                     #
# V1 - 11/08/2015     					      	          #
# V2 - 27/10/2016                                                         #
# V3 - 05/05/2017     					      	          #
# V4 - 11/02/2018     					      	          #
# V5 - 31/05/2019     					      	          #
# It reads the list of vCenter Servers from "./vCenterList.csv" file      #
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
$Connection = Connect-VIServer $VCServer -WarningAction SilentlyContinue
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If ($Connection){
$EsxHost = Get-VMHost 
$ESXReportList = New-Object System.Collections.ArrayList

ForEach ($SingleHost in $EsxHost){

$tempval = New-Object System.Object
$tempval | Add-Member -MemberType NoteProperty -Name "vCenter" -Value $VCServer
$tempval | Add-Member -MemberType NoteProperty -Name "DataCenter" -Value $((Get-Datacenter -VMHost $SingleHost).name)
$tempval | Add-Member -MemberType NoteProperty -Name "Cluster" -Value $((Get-VMHost $SingleHost | Get-Cluster).name)
$tempval | Add-Member -MemberType NoteProperty -Name "ESXi Host" -Value $SingleHost
$tempval | Add-Member -MemberType NoteProperty -Name "CPU Model" -Value $((Get-VMHostHardware -VMHost $SingleHost).CpuModel)
$tempval | Add-Member -MemberType NoteProperty -Name "CPU Count" -Value $((Get-VMHostHardware -VMHost $SingleHost).CpuCount)
$tempval | Add-Member -MemberType NoteProperty -Name "CPU Core Count" -Value $((Get-VMHostHardware -VMHost $SingleHost).CpuCoreCountTotal)
$tempval | Add-Member -MemberType NoteProperty -Name "Installed Memory" -Value $([math]::round((Get-VMHost $SingleHost).MemoryTotalGB))

$State = ((Get-VMHost $SingleHost).ConnectionState).ToString() + "-" + ((Get-VMHost $SingleHost).PowerState).ToString()
$tempval | Add-Member -MemberType NoteProperty -Name "Current State" -Value $State
$tempval | Add-Member -MemberType NoteProperty -Name "Version" -Value $((Get-VMHost $SingleHost).Version)
$tempval | Add-Member -MemberType NoteProperty -Name "Build" -Value $((Get-VMHost $SingleHost).build)
$tempval | Add-Member -MemberType NoteProperty -Name "Make" -Value $((Get-VMHostHardware -VMHost $SingleHost).Manufacturer)
$tempval | Add-Member -MemberType NoteProperty -Name "Model" -Value $((Get-VMHostHardware -VMHost $SingleHost).Model)
$tempval | Add-Member -MemberType NoteProperty -Name "Serial Number" -Value $((Get-VMHostHardware -VMHost $SingleHost).SerialNumber)
$tempval | Add-Member -MemberType NoteProperty -Name "BIOS Version/Release Date" -Value $((((Get-View -ID $SingleHost.Id).Hardware.BiosInfo).BiosVersion).ToString() + " ~ " + (((Get-View -ID $SingleHost.Id).Hardware.BiosInfo).ReleaseDate).tostring())

$ESXReportList.Add($tempval) | Out-Null

}
}
$ESXReportList | Export-csv ".\Report\AllESXiReport.csv" -NoTypeInformation -append
Disconnect-VIServer -Server $VCServer -Confirm:$false
}
