function Confirm-LastExitCode {
    if ($LastExitCode -ne 0) {
        throw "An error occurred executing the previous command. Check its output for more details."
    }
}