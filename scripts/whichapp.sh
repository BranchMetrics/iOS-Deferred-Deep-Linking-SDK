#!/bin/bash

#	whichapp  -  Prints details about a Mac app such as it's installed location, 
#                bundleID, filename, and display name.
#
#	Usage:  whichapp [-bdfhps] [--] <appname>
#
#	Exits code 0 if app is found, 1 otherwise.
#
#	E.B. Smith  -  January 2014

scriptname=whichapp.sh

usage () {
cat <<USAGE

$scriptname  -  Prints information about an OS X application.

Usage: $scriptname [-abdfps] [--] <appname>

Converts a common app name like 'textedit' to:

  * A canonical display name like 'TextEdit'.
  * A filename, like 'TextEdit.app'.
  * A path name, like '/Hard Drive/Applications/TextEdit.app'
  * A bundle ID, like 'com.apple.TextEdit'

Options:

  -a   Prints all application information.
  -b   Prints the application's bundleID.
  -d   Prints the application's display name.
  -f   Prints the application's filename.
  -h   Print this help.
  -p   Prints the applcaition's full path (default).
  -s   Silent mode.

Exits with code 1 if <appname> is not found, 0 otherwise.

USAGE
exit 1
}

set -eu
set -o pipefail

appname=""
bDisplayname=false
bFilename=false
bBundleID=false
bPathname=false
bSilent=false

while getopts ":abdfhps" option; do
	case "$option" in
	a)	bDisplayname=true
		bFilename=true
		bBundleID=true
		bPathname=true
		bSilent=false 
		;;
	b)	bBundleID=true ;; 
	d)  bDisplayname=true ;;
	f)	bFilename=true ;;
	h)  usage ;;
	p)	bPathname=true ;;
	s)	bSilent=true ;;
	?)  echo "Unknown option '-$OPTARG'."; exit 1;; 
	esac
done

appname="${@:$OPTIND:1}"
if [[ ${#appname} == 0 ]]; then
	echo "An <appname> is required."
	usage
	fi

if ! ($bBundleID || $bDisplayname || $bFilename || $bPathname) ; then
	bPathname=true
	fi
	
if $bSilent ; then
	bBundleID=false
	bDisplayname=false
	bFilename=false
	bPathname=false
	fi
	
query="(kMDItemFSName = \"*${appname}*\"cdw && kMDItemKind == \"Application\")"
pathname=$(mdfind "${query}")
count=$(wc -l <<<"${pathname}")
if (( ${#pathname} == 0 )); then
	exit 1
elif (( $count > 1 )); then 
	echo "Too many results." 1>&2
	echo "${pathname}" 1>&2
	exit 1
	fi
	
if $bDisplayname ; then
	echo `mdls -raw -name kMDItemDisplayName "${pathname}"`
	fi
	
if $bFilename ; then
	echo `mdls -raw -name kMDItemFSName "${pathname}"`
	fi

if $bBundleID ; then
	echo `mdls -raw -name kMDItemCFBundleIdentifier "${pathname}"`
	fi

if $bPathname ; then
	echo "${pathname}"
	fi

#DS al fine
