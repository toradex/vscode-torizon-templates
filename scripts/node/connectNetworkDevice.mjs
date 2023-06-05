#!/usr/bin/env node

import { DeviceDetection } from "apollox";
import * as fs from "fs";
import { exit } from "process";

const args = process.argv.slice(2);

async function main() {
    // fetch network devices from the file
    const nets = JSON.parse(
        fs.readFileSync(`${process.env.HOME}/.tcd/scan.json`, "utf8")
    );

    // connect to the arg1 device
    let id = 0
    for (const net of nets) {
        if (id == args[0]) {
            const td = await DeviceDetection.ConnectToDevice(
                net,
                args[1], // login
                args[2], // password
                args[3]  // host ip
            );

            console.log(
                JSON.stringify(td)
            );

            exit(0);
            break;
        }
    }

    // not found
    console.log(JSON.stringify([]));
    exit(404);
}

main();
