#!/bin/sh
#
# Script using rsync to copy torrents downloaded by Transmission to a watch directory for
# post processing immediately upon completion.
# Leaves the source files in the Transmission download directory to continue seeding.
# See trash_seeded_torrent.sh to clean the download directory on a cron schedule.

# AUTHOR: bpgregson https://github.com/bpgregson

# USAGE:
## Make this script executable.  See "chmod --help".
## Stop transmission-daemon
## Edit Transmission .../settings.json
## Enable "script-torrent-done-enabled": true,
## Set "script-torrent-done-filename": /path-to-this-script/rsync_torrent.sh
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
LOG_DIR="/home/$(whoami)/transmission-scripts/logs/rsync_torrent"
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
printf "$TIMESTAMP  Starting to copy $TR_TORRENT_NAME\n" >> $LOG_FILE

# START FILE ACTIONS

# If TR_TORRENT_NAME exists in TR_TORRENT_DIR and is a regular file.
if [ -f "${SRC_NAME}" ]; then
  mkdir -p $DEST_DIR
  rsync -a "$SRC_NAME" "$DEST_DIR"
  SRC_SIZE="$(stat -c%s "$SRC_NAME")"
  DEST_SIZE="$(stat -c%s "$DEST_DIR/$TR_TORRENT_NAME")"
    if [ $SRC_SIZE != $DEST_SIZE ]; then
      printf "WARNING: $TR_TORRENT_NAME File size mismatch: Source size= $SRC_SIZE    Destination size= $DEST_SIZE\n" >> $LOG_FILE
    else
      printf "$TR_TORRENT_NAME  Source size= $SRC_SIZE    Destination size= $DEST_SIZE\n" >> $LOG_FILE
    fi
  TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
  printf "$TIMESTAMP  FINISHED: File $TR_TORRENT_NAME copied to $DEST_DIR\n" >> $LOG_FILE

# If TR_TORRENT_NAME exists in TR_TORRENT_DIR and is a directory.
elif [ -d "${SRC_NAME}" ]; then
  mkdir -p $DEST_DIR
	rsync -a "$SRC_NAME" "$DEST_DIR"
  SRC_SIZE="$(du -sb "$SRC_NAME" | cut -f1)"
  DEST_SIZE="$(du -sb "$DEST_DIR/$TR_TORRENT_NAME" | cut -f1)"
    if [ $SRC_SIZE != $DEST_SIZE ]; then
      printf "WARNING: $TR_TORRENT_NAME Directory size mismatch: Source size= $SRC_SIZE    Destination size= $DEST_SIZE\n" >> $LOG_FILE
    else
      printf "$TR_TORRENT_NAME  Source size= $SRC_SIZE    Destination size= $DEST_SIZE\n" >> $LOG_FILE
    fi
  TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
	printf "$TIMESTAMP  FINISHED: Directory $TR_TORRENT_NAME copied to $DEST_DIR\n" >> $LOG_FILE

# If TR_TORRENT_NAME exists but is neither a regular file nor a directory, send to ERROR_DIR for manual review.
# TO-DO: Additional string if TR_TORRENT_NAME does not exist.  As-is, will exit without logging.
else
	mkdir -p $ERROR_DIR
	rsync -a "$SRC_NAME" "$ERROR_DIR"
# TO-DO: Quality control, compare SRC and DEST file sizes before writing to log.
  TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
	printf "$TIMESTAMP  WARNING: File $TR_TORRENT_NAME copied to $ERROR_DIR\n" >> $LOG_FILE
fi
