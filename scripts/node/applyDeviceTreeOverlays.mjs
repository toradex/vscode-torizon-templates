import * as fs from "fs";
import { exit } from "process";
import { RemoteShellCommand } from "apollox";

const args = process.argv.slice(2);

async function main() {
    const _ip = args[0];
    const _login = args[1];
    const _password = args[2];
    // the list should be name,name,name
    const _raw_overlays = args[3];

    let _overlays = [];
    for (const overlay of _raw_overlays.split(",")) {
        _overlays.push(overlay);
    }

    // get the hash of ostree deployment
    const _hash = await RemoteShellCommand.getOSTreeDeploymentHash(
        {
            Description: "",
            Hostname: _ip,
            Ip: _ip,
            SshPort: 22
        },
        _password,
        _login
    );

    // apply the overlays
    const result = await RemoteShellCommand.applyDeviceTreeOverlays(
        {
            Description: "",
            Hostname: _ip,
            Ip: _ip,
            SshPort: 22
        },
        _password,
        _login,
        _overlays,
        _hash
    );

    // sanity check
    const overlays = await RemoteShellCommand.getDeviceTreeOverlayApplied(
        {
            Description: "",
            Hostname: _ip,
            Ip: _ip,
            SshPort: 22
        },
        _password,
        _login,
        _hash
    )

    console.log(JSON.stringify(overlays));
    exit(0);
}

main();
