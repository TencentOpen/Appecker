#!/bin/bash
set +x

ARG_LIST="a:c:t:l:m:"
APP_ID=''
APP_BINARY=''
TIME_OUT=900
CASE_ID=''
LOG_PATH=''
ALL_CASE_PATH='/tmp/allCaseID.txt'
LOG_NAME='app.log'
SCRIPT_NAME=`basename $0`
MONKEY_CASE_ID=""
TOOL_DIR="/Appecker"


function restartSpringBoard()
{
	echo -n "Restarting SpringBoard..."
	killall -TERM SpringBoard
	sleep 12
	echo  "Done!"
}

function assertToolExist()
{
	echo -n "Checking tool: $1 ..."

	if [ ! -e "/Appecker/$1" ]; then
		echo "Failed!"
		echo "Tool: $1 does not exist in \$PATH or you forget to do chmod +x to it!"
		exit 1
	fi

	echo "Done!"
}

function detectENV()
{
	#Check nessary tools
	assertToolExist "argopen"
	assertToolExist "appid2name"

	#Check appID
    $TOOL_DIR/appid2name ${APP_ID} 1>/dev/null
    
	if [ $? != 0 ]; then
		echo "AppID:${APP_ID} does not exist!"
		exit 1
	fi
} 


function getPID()
{
	pid=`ps aux|grep ${APP_BINARY}|grep -v grep|tr -s " "|cut -d' ' -f 2`
	echo "$pid"
}

function usage()
{
	echo "Usage here!"
}

function getBinaryName
{
	APP_BINARY=`$TOOL_DIR/appid2name ${APP_ID}`
	echo "App binary->>$APP_BINARY"
}

function prepareToRun()
{
	getBinaryName

	cur_dir=`pwd`
	echo "Ready to run!"
}


function killProcess
{
	pid=`getPID`
	if [[ $pid =~ [0-9]+ ]]; then
		echo "Obsolete process found: $pid"
		if [ $1 = "hard" ]; then
			echo -n "Killing process $pid ..."
			kill -KILL $pid
			echo "Done!"
		else
			echo -n "Asking process $pid to quit..."
			kill -TERM $pid
			echo "Done!"
		fi
	fi
}

function killObsoleteProcessHard
{
	killProcess "hard"
}

function killObsoleteProcessSoft
{
	killProcess "soft"
}

function onInterruptExit
{
	echo "iPhone script interrupted!"
	echo "iPhone scriptClean up mess!"

	killObsoleteProcessSoft 
	
	copyLog	

	restartSpringBoard

	trap - INT TERM EXIT
	exit 1
}

function trapSignal()
{
	echo -n "Setup signal trap..."
	trap "onInterruptExit" INT TERM EXIT 
	echo "Done!"
}

function cleanUpCommon()
{
	killObsoleteProcessHard

	restartSpringBoard

	rm -rf "$LOG_PATH/$LOG_NAME"
	find /private/var/mobile/Applications -name app.log -exec rm -rf "{}" \;
	find /var/mobile/Documents -name app.log -exec rm -rf "{}" \;
}

function cleanUpMonkeyMode()
{
	echo "Clean up for monkey mode..."
	cleanUpCommon
}

function cleanUpCompoundMode()
{
	echo "Clean up for compound mode..."
	cleanUpCommon
	rm -rf "$ALL_CASE_PATH"
}

function cleanUpSingleMode()
{
	echo "Clean up for single mode..."
	cleanUpCommon
}


function appOnLine 
{
	pid=`getPID`
	if [ -z "${pid}" ]; then
		return 1
	fi

	return 0
}


function waitForAppExit()
{
	echo "Waiting for app to exit..."
	while appOnLine
	do
		echo "App is still running with pid:${pid}, waiting for one more second..."
		sleep 1
	done

	echo "App exited!"
}

function waitForAppStart()
{
	echo "Waiting for app to start..."
    maxWaitTime=4
    timeElapsed=0
	while ! appOnLine
	do
		echo "App is not yet running, waiting for 1 sec...."
		sleep 1
        timeElapsed=`expr $timeElapsed + 1`
        if [ $timeElapsed -eq $maxWaitTime ]; then
            return 1
        fi
	done
    return 0
}


function makeSureAppOnLine()
{
	while :
	do
		$TOOL_DIR/argopen ${APP_ID} -caseid "$1" 1>/dev/null 2>&1
		if waitForAppStart; then
			echo "App started!"
			break
		fi
		echo "App failed to start up, retrying..."
	done
}


function runSingleCase()
{
	counter=0
	caseID="$1"
	
	echo "Running case $caseID..."
	makeSureAppOnLine "$caseID"

	while :
	do
		sleep 1
		pid=`getPID`
		if [ -z "$pid" ]; then
			break;
		elif [ $counter -eq $TIME_OUT ];then
			echo "$caseID is time out!"
			kill -TERM $pid
			echo "SIGTERM is sent to $caseID!"
			waitForAppExit
			break;
		else
			counter=`expr $counter + 1`
			echo "$caseID is running(pid:${pid}) ..."
		fi

	done
	
	restartSpringBoard
}

function runInMonkeyMode()
{
	echo "Running in monkey mode...."		
	cleanUpMonkeyMode
	makeSureAppOnLine "$MONKEY_CASE_ID"

	while :
	do
		if ! appOnLine ;then
			echo "Oops, Monkey is dead!"

			restartSpringBoard

			makeSureAppOnLine "$MONKEY_CASE_ID"
		fi
		sleep 1
		echo "Monkey is alive with pid:`getPID`..."
	done
	echo "Monkey mode finished!"	
}

function runInCompoundMode()
{
	echo "Running in compound mode..."
	
	cleanUpCompoundMode

	$TOOL_DIR/argopen ${APP_ID} -outputcases "$ALL_CASE_PATH" 1>/dev/null 2>&1 #This step is asynchronous, so we will have to sleep for some time
	
	echo -n "Waiting for app to generate all caseIDs..."
	sleep 5
	echo "Done!"
	
	if [ ! -e "$ALL_CASE_PATH" ];then
		echo "Error: Can't generate $ALL_CASE_PATH"
		exit 1
	fi


	echo "All caseIDs are written to:$ALL_CASE_PATH"
	
	for caseID in `cat $ALL_CASE_PATH`
	do
		runSingleCase "$caseID"
	done

	echo "Compound mode finished!"
}

function runInSingleMode()
{
	echo "Running in signle mode..."
	cleanUpSingleMode
	runSingleCase "$CASE_ID"
	echo "Single mode finished!"
}


function copyLog
{
	log=`find /private/var/mobile/Applications -name app.log`
	
	if [ -z "$log" ]; then
		log=`find /var/mobile/Documents -name app.log`
	fi

	echo "Log is found here:$log"
	echo "Copy log to $LOG_PATH"
	cp -f "$log" "$LOG_PATH"
}

clear

echo "===========Appecker Automation Script Suit v0.1==========="


while getopts $ARG_LIST opt; do
    case $opt in
        a)
			APP_ID="$OPTARG";;
        c)
            CASE_ID="$OPTARG";;
        t)
			TIME_OUT="$OPTARG";;
		l)
			LOG_PATH="$OPTARG";;
		m)
			MONKEY_CASE_ID="$OPTARG";;
        ?)
			exit 1
            ;;
    esac
done

if [ ! -z $MONKEY_CASE_ID ] && [ ! -z $CASE_ID ];then
	echo "You can't specify -c and -m at the same time!"
	exit 1
fi


if [ -z "$APP_ID" ]; then
	echo "You must pass a valid app ID!"
	exit 1
fi


echo "App ID:$APP_ID"

detectENV


if [ -z $LOG_PATH ]; then
	LOG_PATH=`dirname $0`
	LOG_PATH=`pwd $LOG_PATH`
	echo "No log location, assuming default..."
fi

echo "Log will be put here:$LOG_PATH"

echo "Timeout:$TIME_OUT sec"

prepareToRun

trapSignal

if [ -z $MONKEY_CASE_ID ]; then
	if [ -z $CASE_ID ]; then
		runInCompoundMode
	else
		runInSingleMode
	fi
else
	runInMonkeyMode
fi

copyLog

echo "iPhone script finished!"

trap - INT TERM EXIT
