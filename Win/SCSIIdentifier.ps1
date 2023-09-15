$temporal = Get-WmiObject Win32_DiskDrive | ForEach-Object {
   $disk = $_
   $partitions = "ASSOCIATORS OF " +
                 "{Win32_DiskDrive.DeviceID='$($disk.DeviceID)'} " +
                 "WHERE AssocClass = Win32_DiskDriveToDiskPartition"
   Get-WmiObject -Query $partitions | ForEach-Object {
     $partition = $_
     $drives = "ASSOCIATORS OF " +
               "{Win32_DiskPartition.DeviceID='$($partition.DeviceID)'} " +
               "WHERE AssocClass = Win32_LogicalDiskToPartition"
     Get-WmiObject -Query $drives | ForEach-Object {
       New-Object -Type PSCustomObject -Property @{
         Disk        = $disk.DeviceID
         SCSIController = $disk.scsiport;
         SCSIDevice = $disk.scsitargetid
         DiskModel   = $disk.Model
         Partition   = $partition.Name
         DriveLetter = $_.DeviceID
         SizeGB      = [math]::Round($_.Size / 1GB, 0)
         FreeSpaceGB = [math]::Round($_.FreeSpace / 1GB, 0)
       }
     }
   }
} | ft
