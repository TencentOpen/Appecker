#!/bin/bash
APP_ID=""
CASE_ID=""
TIME_OUT=900
LOG_PATH=""
MONKEY_CASE_ID=""
IPHONE_IP=""
APP_PATH=""
ARG_LIST="a:c:t:l:m:i:p:"
IP_PATTERN="^(([0-9]|[1-9][0-9]|1[0-9]{2}|2([0-4][0-9]|5[0-5]))\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2([0-4][0-9]|5[0-5]))$"

echo "===========Appecker Automation Script Suit v0.1==========="


function removeTweakFile
{
	echo -n "Remove file: $1 ..."
	ssh root@$IPHONE_IP "rm -rf /Library/MobileSubstrate/DynamicLibraries/$1"
	echo "Done!"
}

function cleanENV
{
	echo "Cleaning environment:"
	
	echo -n "Removing old scripts and binaries..."
	ssh root@$IPHONE_IP "rm -rf /Appecker"
	echo "Done!"

	echo "Removing Tweak Module..."
	removeTweakFile "Appid2name.dylib"
	removeTweakFile "Appid2name.plist"
	removeTweakFile "Open.dylib"
	removeTweakFile "Open.plist"
}

function deployTweakFile
{
	scp $1 root@$IPHONE_IP:/Library/MobileSubstrate/DynamicLibraries
}

function deployTools
{
	echo -n "Deploying scripts and binaries..."
	ssh root@$IPHONE_IP "mkdir /Appecker"
	ssh root@$IPHONE_IP "chmod 777 /Appecker"
	scp Tool/autorun2.sh Tool/appid2name Tool/argopen root@$IPHONE_IP:/Appecker
	echo "Done!"

	echo -n "Preparing files to be run..."
	ssh root@$IPHONE_IP "chmod +x /Appecker/*"
	echo "Done!"

	echo "Deploying Tweak Module..."
	deployTweakFile "Tool/Appid2name.dylib"
	deployTweakFile "Tool/Appid2name.plist"
	deployTweakFile "Tool/Open.dylib"
	deployTweakFile "Tool/Open.plist"
}

function deployApp
{
	echo "Deploying app..."
	
	app_name=`basename $APP_PATH`
	
	if [[ !("$app_name" =~ \.app$) ]]; then
		echo "App name: $app_name does NOT seem to be right(It should look like abc.app)!"
		exit 1
	fi

	echo "Removing old app..."
	ssh root@$IPHONE_IP "rm -rf /Applications/$app_name"
	ssh root@$IPHONE_IP "rm -rf /var/mobile/Applications/AppeckerSUT"
	echo "Done!"

	echo "Upload app to iPhone..."
	ssh root@$IPHONE_IP "mkdir /var/mobile/Applications/AppeckerSUT"
	ssh root@$IPHONE_IP "mkdir /var/mobile/Applications/AppeckerSUT/Documents"
	scp -r $APP_PATH root@$IPHONE_IP:/var/mobile/Applications/AppeckerSUT/$app_name
	ssh root@$IPHONE_IP "chmod -R 777 /var/mobile/Applications/AppeckerSUT"

}

function retrieveLog
{
	echo "Retrieving log to $LOG_PATH ..."
	scp root@$IPHONE_IP:/Appecker/app.log $LOG_PATH
}


function restartSpringBoard
{
	echo -n "Restarting SpringBoard..."
	ssh root@$IPHONE_IP "killall -TERM SpringBoard"
	sleep 6
	echo "Done!"
}

function runInCompoundMode
{
	echo  "Starting running in compound mode..."
	
	ssh root@$IPHONE_IP "/Appecker/autorun2.sh -a $APP_ID -t $TIME_OUT -l /Appecker"	

}

function runInSingleMode
{
	echo -n "Starting running in single mode..."
	
	ssh root@$IPHONE_IP "/Appecker/autorun2.sh -a $APP_ID -c $CASE_ID -t $TIME_OUT -l /Appecker"

	echo "Done!"
}

function runInMonkeyMode
{
	echo -n "Starting running in monkey mode..."

	ssh root@$IPHONE_IP "/Appecker/autorun2.sh -a $APP_ID -m $MONKEY_CASE_ID -t $TIME_OUT -l /Appecker" 

	echo "Done!"

}

function shutdownAutorun
{
	pids=(`ssh root@$IPHONE_IP "ps aux | grep autorun2.sh | grep -v grep | tr -s ' ' | cut -d' ' -f2"`)
	
	if [ -z "$pids" ]; then
		echo "No autorun instance detected!"
		return 1
	fi

	while [ ${#pids[*]} -ne 1 ]
	do
		sleep 1
		pids=(`ssh root@$IPHONE_IP "ps aux | grep autorun2.sh | grep -v grep | tr -s ' ' | cut -d' ' -f2"`)
	done

	echo -n "autorun instance found(pid = $pids), asking to quit..."
	ssh root@$IPHONE_IP "kill -TERM $pids"
	echo "Done!"

	return 0

}

function trapSignal()
{
	echo -n "Setup signal trap..."
	trap "onInterruptExit" SIGINT SIGTERM 
	echo "Done!"
}

function onInterruptExit()
{
	echo "Local Script Interrupted!"
	echo "Clean up mess!"	
	
	retrieveLog
}

trapSignal

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
		i)
			IPHONE_IP="$OPTARG";;
		p)
			APP_PATH="$OPTARG";;
        ?)
			exit 1
            ;;
    esac
done


if [ -z "$APP_PATH" ]; then
	echo "You must specify target app path by -p arguement!"
	exit 1
fi

if [ ! -e "$APP_PATH" ]; then
	echo "App path: $APP_PATH does NOT exist!"
	exit 1
fi

if [ -z $IPHONE_IP ]; then
	echo "You must specify a ip address of iPhone!"
	exit 1
fi

if [[ !($IPHONE_IP =~ $IP_PATTERN) ]] ; then
	echo "The ip address:$IPHONE_IP is invalid!"
	exit 1
fi

if [ ! -z $MONKEY_CASE_ID ] && [ ! -z $CASE_ID ];then
	echo "You can't specify -c and -m at the same time!"
	exit 1
fi


if [ -z "$APP_ID" ]; then
	echo "You must pass a valid app ID!"
	exit 1
fi

if [ -z $LOG_PATH ]; then
	LOG_PATH=`dirname $0`
	LOG_PATH=`pwd $LOG_PATH`
	echo "No log location, assuming default..."
fi

echo "Log will be put here:$LOG_PATH"

echo "Timeout:$TIME_OUT sec"

shutdownAutorun

cleanENV

deployTools

deployApp

restartSpringBoard

if ! ssh root@$IPHONE_IP "/Appecker/appid2name $APP_ID" 1>/dev/null 2>&1
then
	echo "AppID:$APP_ID does NOT exist or iPhone ip address is incorrect!"
	exit 1
fi

echo "App ID:$APP_ID"



if [ -z $MONKEY_CASE_ID ]; then
	if [ -z $CASE_ID ]; then
		runInCompoundMode
	else
		runInSingleMode
	fi
else
	runInMonkeyMode
fi

retrieveLog

echo "Mac script finished!"
