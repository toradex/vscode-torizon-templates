#!/usr/bin/env node

import { DeviceDetection } from "apollox"; 

async function main() {
    // disable console.log
    const _clTmp = console.log;
    console.log = function() {};

    const nets = await DeviceDetection.GetNetworkDevices();

    // enable console.log
    console.log = _clTmp;

    // output
    console.log(
        JSON.stringify(nets)
    );
}

main();
