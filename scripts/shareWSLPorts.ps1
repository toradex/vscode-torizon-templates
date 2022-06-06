
# this only makes sense for WSL
if ($null -ne $env:WSL_DISTRO_NAME) {
    $remoteport = bash -c "ifconfig eth0 | grep 'inet '"
    $found = $remoteport -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

    if( $found ){
        $remoteport = $matches[0];
    } else{
        Write-Output "The Script Exited, the ip address of WSL 2 cannot be found";
        exit;
    }

    #[Ports]

    #All the ports you want to forward separated by coma
    $ports=@(8090, 5000);
    $superScript = "";

    #[Static ip]
    #You can change the addr to your ip config to listen to a specific address
    $addr='0.0.0.0';
    $ports_a = $ports -join ",";

    #Remove Firewall Exception Rules
    $superScript = "($superScript Remove-NetFireWallRule -DisplayName ApolloX) -or `$true &&";

    #adding Exception Rules for inbound and outbound Rules
    $superScript = "$superScript New-NetFireWallRule -DisplayName ApolloX -Direction Outbound -LocalPort $ports_a -Action Allow -Protocol TCP &&";
    $superScript = "$superScript New-NetFireWallRule -DisplayName ApolloX -Direction Inbound -LocalPort $ports_a -Action Allow -Protocol TCP &&";

    for( $i = 0; $i -lt $ports.length; $i++ ){
        $port = $ports[$i];
        $superScript = "$superScript netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$addr &&";
        $superScript = "$superScript netsh interface portproxy add v4tov4 listenport=$port listenaddress=$addr connectport=$port connectaddress=$remoteport &&";
    }

    $superScript = $superScript.Trim();

    pwsh.exe -C "start-process pwsh -verb runas -ArgumentList '-C `"$superScript echo done`"'"
}
