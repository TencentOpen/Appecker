#!/bin/bash
set +x

SDK_VER=''
ARG_LIST="a:c:t:l:s:m:"
APP_PATH=''
APP_BINARY=''
TIME_OUT=900
CASE_ID=''
LOG_PATH=''
ALL_CASE_FILE='allCaseID.txt'
ALL_CASE_PATH=''
LOG_NAME='app.log'
SCRIPT_NAME=`basename $0`
SPECIFIED_SDK=""
MONKEY_CASE_ID=""

function detectSDK()
{
	sdks=(`./ios-sim showsdks 2>&1|grep '(' | cut -d '(' -f 2 | cut -d ')' -f 1`)
	if [ ${#sdks[*]} -ne 1 ]; then
		if [ -z $SPECIFIED_SDK ]; then
			echo "Detected multipule sdks:"
			for s in ${sdks[*]}
			do
				echo $s
			done
			echo "Please specify one using -s argument!"
			exit -1
		else
			SDK_VER="$SPECIFIED_SDK"
		fi
	else	
		SDK_VER=`echo ${sdks[0]} | cut -d '(' -f 2 | cut -d ')' -f 1`
	fi

	echo "Using sdk:$SDK_VER"

	return 0

} 


function getPID()
{
	pid=`ps xww | grep $APP_BINARY | grep "iPhone Simulator" | grep -v grep | grep -v ios-sim| grep -v $SCRIPT_NAME | cut -b 1-6`
	echo "$pid"
}

function killSimulator()
{
	#kill the existing simulator process
	PID=`ps xww | grep "iPhone Simulator.app" | grep -v grep | cut -b 1-8`

	if [ ! -z "${PID}" ]; then
	  echo -n "Terminating iPhone Simulator..."
	  kill -TERM $PID
	  echo "Done!"
	fi 
}

function usage()
{
	echo "Usage here!"
}

function getBinaryName
{
	app_name=`basename "$APP_PATH"`

	APP_BINARY=`echo $app_name|cut -d "." -f 1`
	echo "App binary->>$APP_BINARY"
}

function prepareToRun()
{
	echo "Prepare ios-sim to be run from command line!"
	chmod +x ./ios-sim

	getBinaryName

	cur_dir=`pwd`
	ALL_CASE_PATH=$cur_dir/$ALL_CASE_FILE
	echo "Ready to run!"
}

function killObsoleteProcess
{
	pid=`getPID`	
	
	if [[ $pid =~ [0-9]+ ]]; then
		echo "Obsolete process found: $pid"
		echo -n "Terminating..."
		kill -TERM $pid
		echo "Done!"
	fi
}

function onInterruptExit
{
	echo "Interrupted!"
	echo "Clean up mess!"

	killObsoleteProcess 
	
	killSimulator
	
	copyLog

	exit 1
	
}

function trapSignal()
{
	echo -n "Setup signal trap..."
	trap "onInterruptExit" SIGINT SIGTERM 
	echo "Done!"
}


function cleanUpCommon()
{

	rm -rf "$ALL_CASE_PATH"
	rm -rf "$LOG_PATH/$LOG_NAME"
	find ~ -name app.log -exec rm -rf "{}" \;
	
	killObsoleteProcess 
}

function cleanUpMonkeyMode()
{
	echo -n "Clean up for monkey mode..."
	cleanUpCommon
	echo "Done!"
}

function cleanUpCompoundMode()
{
	echo -n "Clean up for compound mode..."
	cleanUpCommon
	rm -rf "/tmp/$ALL_CASE_FILE"
	echo "Done!"
}

function cleanUpSingleMode()
{
	echo -n "Clean up for single mode..."
	cleanUpCommon
	echo "Done!"
}


function runSingleCase()
{
	counter=0
	caseID="$1"
	
	echo "Running case $caseID..."
	./ios-sim launch "$APP_PATH" --sdk $SDK_VER --exit --args -caseid "$caseID" 1>/dev/null 2>&1
	while :
	do
		sleep 1
		pid=`getPID`
		if [ -z "$pid" ]; then
			break;
		elif [ $counter -eq $TIME_OUT ];then
			echo "$caseID is time out!"
			kill -TERM $pid
			echo "$caseID is killed with SIGTERM!"
			break;
		else
			counter=`expr $counter + 1`
			echo "Waiting $caseID to finish..."
		fi


	done
	

}

function runInMonkeyMode()
{
	echo "Running in monkey mode...."		
	cleanUpMonkeyMode
	./ios-sim launch "$APP_PATH" --sdk $SDK_VER --exit --args -caseid "$MONKEY_CASE_ID" 1>/dev/null 2>&1
	while :
	do
		sleep 1
		echo "Monkey is alive..."
		pid=`getPID`
		if [ -z "$pid" ]; then
			echo -n "Oops, Monkey is dead, restarting..."
			./ios-sim launch "$APP_PATH" --sdk $SDK_VER --exit --args -caseid "$MONKEY_CASE_ID" 1>/dev/null 2>&1
			echo "Done!"
		fi
	done
	echo "Monkey mode finished!"	
}

function runInCompoundMode()
{
		echo "Running in compound mode..."
		
		cleanUpCompoundMode

		./ios-sim launch "$APP_PATH" --sdk $SDK_VER --args -outputcases "/tmp/$ALL_CASE_FILE" 1>/dev/null 2>&1
		
		if [ ! -e "/tmp/$ALL_CASE_FILE" ];then
			echo "Error: Can't generate $ALL_CASE_FILE"
			exit -1
		fi

		cp "/tmp/$ALL_CASE_FILE" $ALL_CASE_PATH

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
	log=`find ~ -name app.log`
	echo "Log is found here:$log"
	echo "Copy log to $LOG_PATH"
	cp -f "$log" "$LOG_PATH"
}

clear

echo "===========Appecker Automation Script Suit v0.1==========="





while getopts $ARG_LIST opt; do
    case $opt in
        a)
			APP_PATH="$OPTARG";;
        c)
            CASE_ID="$OPTARG";;
        t)
			TIME_OUT="$OPTARG";;
		l)
			LOG_PATH="$OPTARG";;
		s)
			SPECIFIED_SDK="$OPTARG";;
		m)
			MONKEY_CASE_ID="$OPTARG";;
        ?)
			exit -1
            ;;
    esac
done

if [ ! -z $MONKEY_CASE_ID ] && [ ! -z $CASE_ID ];then
	echo "You can't specify -c and -m at the same time!"
	exit -1
fi


if [ -z "$APP_PATH" ]; then
	echo "You must pass a valid app path!"
	exit -1
fi

if [ ! -d "$APP_PATH" ]; then
    echo "App path [$APP_PATH] does NOT exist!"
    exit -1
fi


echo "App path at:$APP_PATH"

detectSDK


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

echo "All Done!"
