#!/usr/bin/env node

import { DeviceDetection } from "apollox";

async function main() {
    // disable console.log
    const _clTmp = console.log;
    console.log = function() {};

    // show the devices found in async mode
    const devDect = new DeviceDetection((dev) => {
        _clTmp(
            JSON.stringify(dev)
        );
    });

    const nets = await devDect.ScanDevices();

    // enable console.log
    console.log = _clTmp;

    // output
    console.log(
        JSON.stringify(nets)
    );
}

main();
