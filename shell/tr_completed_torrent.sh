#!/bin/sh
#
# Script to prepare torrents downloaded by Transmission for action by
# rsync_torrent.sh immediately upon completion.

# AUTHOR: bpgregson https://github.com/bpgregson

# USAGE:
## Make this script executable.  See "chmod --help".
## Stop transmission-daemon
## Edit Transmission .../settings.json
## Enable "script-torrent-done-enabled": true,
## Set "script-torrent-done-filename": /path-to-this-script/tr_completed_torrent.sh
## Restart Transmission

#################################################################################
# These are inherited from Transmission.                                        #
# Do not declare these. Just use as needed.                                     #
#                                                                               #
# TR_APP_VERSION                                                                #
# TR_TIME_LOCALTIME                                                             #
# TR_TORRENT_DIR                                                                #
# TR_TORRENT_HASH                                                               #
# TR_TORRENT_ID                                                                 #
# TR_TORRENT_NAME                                                               #
#                                                                               #
#################################################################################

#################################################################################
#                                    CONFIG                                     #
#                     variable parameters, configure as needed                  #
#################################################################################

DEST_DIR="/media/nas/PostProcessing/Watch"
ERROR_DIR="/media/nas/PostProcessing/Manual_Process"
SCRIPT_DIR="/home/$(whoami)/transmission-scripts"
LOG_DIR="$SCRIPT_DIR/logs/rsync_torrent"
LOG_DATE=$(date -I)  # date options determine frequency of new files.  See "date --help".
LOG_FILE="$LOG_DIR/rsync_torrent_$LOG_DATE.log"

#################################################################################
#                                 SCRIPT CONTROL                                #
#                               edit with caution                               #
#################################################################################

# get path
SRC_NAME="$TR_TORRENT_DIR/$TR_TORRENT_NAME"

# start logging
mkdir -p $LOG_DIR
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
printf "$TIMESTAMP Starting to copy $TR_TORRENT_NAME\n" >> $LOG_FILE

# START FILE ACTIONS
$SCRIPT_DIR/shell/rsync_torrent.sh

