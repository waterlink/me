#!/usr/bin/env bash

echo -n "free" > tests.lock

function termtitle {
    echo -ne "\033]0;${1}\007"
}

function success {
    notify-send "SUCCESS" -i face-angel -t 300
    termtitle "SUCCESS"
}

function failure {
    notify-send "FAILURE" -i face-angry -t 300
    termtitle "FAILURE"
}

function run_rspec {
    rspec && success || failure
    echo -n "free" > tests.lock
}

function run_tests {
    lock=$(cat tests.lock)
    if [[ "$lock" = "free" ]]; then
        echo -n "taken" > tests.lock
        run_rspec &
    fi
}

inotifywait -r -m -e modify --format '%w%f' lib spec 2>/dev/null | while read line; do
    echo $line
    run_tests
done
