#!/bin/bash
################################################################
# Set this up as a cron job. eg:-
#   m h  dom mon dow   command
#   0 */1 * * 0,1,2,3,4 /home/foo/imaginea-login.sh > /dev/null
# fyi: juniper session timeout is set at 11 hrs.
################################################################
#//TODO: cygwin,darwin compatibility and windows service
#//TODO: move out $fileName to args.
#//TODO: moveout host1,host2 for internet and intranet out.
scriptPath() {
    pushd . > /dev/null
    SCRIPT_PATH="${BASH_SOURCE[0]}";
    while([ -h "${SCRIPT_PATH}" ]); do
        cd "`dirname "${SCRIPT_PATH}"`"
        SCRIPT_PATH="$(readlink "`basename "${SCRIPT_PATH}"`")";
    done
    cd "`dirname "${SCRIPT_PATH}"`" > /dev/null
    SCRIPT_PATH="`pwd`";
    popd  > /dev/null
    echo "${SCRIPT_PATH}"
}

. $(scriptPath)/autologin.conf

alarm() {
    if hash beep 2>/dev/null; then
	beep -f 1000 -n -f 2000 -n -f 1500
    fi
}
isLoginSuccess() {
    success=1
    if grep "$message_grep" "$tmp_file"> /dev/null ; then
	success=0
    fi
    return $success
}

doLogin() {
    pwd=`pass "$pwd_key"`
    curlAgrs1="-v --cookie-jar cjar --output /dev/null $intranet_host2"
    curlArgs2="-v --cookie cjar --cookie-jar cjar --data username=$userid --data password=$pwd --data login=login --location --output $tmp_file http://$intranet_host2/webauth?target="

eval curl $curlArgs1
eval curl $curlArgs2
    
}
isInternetUp() {
    isNetworkUp $internet_host1 $internet_host2
}

isNetworkUp() {
    echo "$1  $2"
    (ping -w5 -c3 $1 || ping -w5 -c3 $2) > /dev/null 2>&1
}

isIntranetUp() {
    isNetworkUp $intranet_host1 $intranet_host2
}

if isIntranetUp; then
    if isInternetUp; then 
       echo 'Internet UP'
    else
	for i in {1..3}
	do
	    doLogin
	    if isLoginSuccess; then
		break
	    else
		alarm
                sleep 5
	    fi
	done
    fi
else
	alarm
fi
