#!/usr/bin/env bash
# Plex DVR Postprocessing
# Version 0.0.2
# macmacs
#
# Dependencies:
#   ts -->  apt install moreutils

# TRANSCODE AND COMPRESS

LOCK_FILE='/tmp/dvrProcessing.lock'
INPUT_FILE="$1"
TMP_FILE=$(mktemp)
LOG_FILE='/tmp/dvrProcessing.log'
HANDBRAKE_CLI=`which HandBrakeCLI`


rm -f ${LOG_FILE}
log() {
  echo "$@" | ts | tee -a ${LOG_FILE}
}

if [[ -z ${HANDBRAKE_CLI} ]]; then
  log "Handbrake CLI not installed! Aborting ..."
  exit 1
fi

log "PLEX DVR Postprocessing script started"

# Check if post processing is already running
while [[ -f ${LOCK_FILE} ]]
do
    log "$LOCK_FILE' exists, sleeping processing of '$INPUT_FILE'"
    sleep 10
done

# Create lock file to prevent other post-processing from running simultaneously
log "Creating lock file for processing '$INPUT_FILE'"
touch ${LOCK_FILE}

# Encode file to MP4 with handbrake-cli
log "Transcoding started on '$INPUT_FILE'"
${HANDBRAKE_CLI} -i "$INPUT_FILE" -o "$TMP_FILE" --preset="H.264 MKV 576p25" --encoder-preset="veryfast" -O

# Overwrite original ts file with the transcoded file
log "File rename started"
mv -f "$TMP_FILE" "${INPUT_FILE}.mkv"
rm -f "${INPUT_FILE}"

#Remove lock file
log "All done! Removing lock for '$INPUT_FILE'"
rm -f ${LOCK_FILE}

exit 0
