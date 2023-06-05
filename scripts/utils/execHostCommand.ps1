
function ExecHostCommand() {
    return $(sudo nsenter -t 1 -m -u -n -i -- $args)
}
