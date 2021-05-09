# Zabbix Trapper protocol in Powershell

Zabbix is a monitoring server. It supports different types of monitoring protocols. There is Zabbix [Trapper item](https://www.zabbix.com/documentation/current/manual/config/items/itemtypes/trapper) type. It allows send values to Zabbix server by [specific](https://www.zabbix.com/documentation/current/manual/appendix/items/trapper) [protocol](https://www.zabbix.com/documentation/current/manual/appendix/protocols/header_datalen). Usually it's used with `zabbix_sender` utility that sends data to the server. It works in scenario when you can't or won't install Zabbix agent on monitoring machine.  
The protocol has implementation in different languages. This example demonstrates Powershell and Windows Performance Counter. All thanks go to [sawfriendship](https://sawfriendship.wordpress.com/2017/03/29/powershell-send-zabbixtrap/) for [implementation](https://www.powershellgallery.com/packages/Send-ZabbixTrap/1.2/Content/Send-ZabbixTrap.ps1).  
You could see available counters and description in Performance Monitor  
Example list performance counter for physical disk  
   > (Get-Counter -List PhysicalDisk).PathsWithInstances  

This example demonstrates:  
- Get Windows Performance Counter for specific metrics  
- Create JSON object  
- Send TCP stream with header and data to server  
- Get reply from the server  

You could create a Scheduled Task to run on regular basis and put performance counter value to Zabbix server.  

Notes to command  
- Replace `zabbix.server` with Zabbix server addresss. This server should allow incoming connection to port 10051  
- Repalce `client.host` with monitored hostname. This host should have been created on Zabbix server  
- Create trapper item types with keys: `disk.time`, `disk.wait`, `disk.queue`, `disk.free`, `proc.time`, `mem.free`, `paging.use`, `proc.queue` on Zabbix server host. This is critical that Zabbix server has host and items configured before sending this information  
