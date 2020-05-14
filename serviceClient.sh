serviceClient()
(

    showUsage()
    (
        echo "This should be a help page"
    ) >&2
    
    isValidArg()
    (
        test "$(type -t "$1")" = "function"
    )
    
    isRunning()
    (
        nc -zw1 "$(getHostname)" "$(getPortNumber)"
    ) &>/dev/null
    
    getHostname()
    (
        echo localhost
    )
    
    getPortNumber()
    (
        echo 80
    )
    
    getStatus()
    (
        if isRunning
        then echo OK
        else echo DOWN
        fi
    )
    
    getErrorCount()
    (
        grep -c "ERROR" /var/log/apache2/error.log
    )
    
    printDetails()
    (
        echo "Service status: $(getStatus)"
        echo "Errors logged: $(getErrorCount)"
    )
    
    if isValidArg "$1"
    then
            "$1"
    else
            showUsage
    fi
)

echo $@

serviceClient $1
