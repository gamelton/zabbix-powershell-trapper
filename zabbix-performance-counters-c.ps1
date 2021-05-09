$zabbixServer = 'zabbix.server'
$zabbixPort = '10051'
$chost = 'client.host'
$pc_disktime = (Get-Counter -Counter "\PhysicalDisk(0 C:)\% Disk Time").CounterSamples.CookedValue
$pc_diskwait = (Get-Counter -Counter "\PhysicalDisk(0 C:)\Avg. Disk sec/Transfer").CounterSamples.CookedValue
$pc_diskqueue = (Get-Counter -Counter "\PhysicalDisk(0 C:)\Avg. Disk Queue Length").CounterSamples.CookedValue
$pc_diskfree = (Get-Counter -Counter "\LogicalDisk(C:)\Free Megabytes").CounterSamples.CookedValue
$pc_proctime = (Get-Counter -Counter "\Processor(_Total)\% Processor Time").CounterSamples.CookedValue
$pc_memfree = (Get-Counter -Counter "\Memory\Available MBytes").CounterSamples.CookedValue
$pc_paginguse = (Get-Counter -Counter "\Paging File(_Total)\% Usage").CounterSamples.CookedValue
$pc_procqueue = (Get-Counter -Counter "\System\Processor Queue Length").CounterSamples.CookedValue

$Json = [pscustomobject][ordered]@{'request' = 'sender data' ;'data' = @([pscustomobject][ordered]@{'host' = $chost; 'key' = 'disk.time';'value' = $pc_disktime},@{'host' = $chost; 'key' = 'disk.wait';'value' = $pc_diskwait},@{'host' = $chost; 'key' = 'disk.queue';'value' = $pc_diskqueue},@{'host' = $chost; 'key' = 'disk.free';'value' = $pc_diskfree},@{'host' = $chost; 'key' = 'proc.time';'value' = $pc_proctime},@{'host' = $chost; 'key' = 'mem.free';'value' = $pc_memfree},@{'host' = $chost; 'key' = 'paging.use';'value' = $pc_paginguse},@{'host' = $chost; 'key' = 'proc.queue';'value' = $pc_procqueue})} | ConvertTo-Json -Compress

[byte[]]$Header = @([System.Text.Encoding]::ASCII.GetBytes('ZBXD')) + [byte]1
[byte[]]$Length = @([System.BitConverter]::GetBytes($([long]$Json.Length)))
[byte[]]$Data = @([System.Text.Encoding]::ASCII.GetBytes($Json))
    
$All = $Header + $Length + $Data

$Socket = New-Object System.Net.Sockets.Socket ([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
$Socket.Connect($zabbixServer,$zabbixPort)
$Socket.Send($All) | Out-Null
[byte[]]$Buffer = New-Object System.Byte[] 1000
[int]$ReceivedLength = $Socket.Receive($Buffer)
$Socket.Close()

$Received = [System.Text.Encoding]::ASCII.GetString(@($Buffer[13 .. ($ReceivedLength - 1)]))
$Received | ConvertFrom-Json
