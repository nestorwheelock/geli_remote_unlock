#!/usr/bin/env bash

set -e

SELF_DIR="$(cd "$(dirname "$0")" && pwd || exit 2)"

# shellcheck source=remote/config.sample.sh
source "$SELF_DIR/config.sh"


# Parse the request. Using $* for local debugging
INPUT="$SSH_ORIGINAL_COMMAND"
[ -z "$INPUT" ] && INPUT="$*"
# Split the request into separate variables
IFS=' ' read -r COMMAND FILE <<< "$INPUT"


# Before doing anything else, send the alert mail (if configured)
[ -x "$ALERT_SCRIPT" ] && "${ALERT_SCRIPT}"

# Nestor Wheelock
# Started thinking about how to add other steps like maybe how to use the users password 
# hash to add a layer of local authentication. Maybe this would be a good place to do 
# multifactor/OAUTH?  Then if this is deployed on a subscription SAAS managed equipment
# It could boot and then look for more things from the server, updated configs, CVE scan logs,
# etc etc.


# helper function to signal some error and exit
err() {
	(>&2 echo "error")
	[ -n "$*" ] && (>&2 echo "$*")
	exit 1
}
# helper function to safely retrieve file contents
get() {
	[ ! -d "$1" ] && err "directory not found"
	[ ! -n "$2" ] && err "empty request"
	case $2 in
		*\.\.*) err "no double dots allowed" ;;
		*/*) err "no slashes allowed" ;;
	esac
	[ ! -r "$1/$2" ] && err "file not found"
	cat "$1/$2"
}

# parse known commands
case $COMMAND in
	keyfile)
		get "$DIR_KEYS" "$FILE"
		;;
	passphrase)
		get "$DIR_PASS" "$FILE"
		;;
	*)
		err
		;;
esac

exit 0
