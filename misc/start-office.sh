#!/bin/bash
# Free sound samples from:
# https://mixkit.co/free-sound-effects/office/
# https://pixabay.com/sound-effects/search/office%20background/

# NOTES:
# aplay is designed for uncompressed audio formats like WAV, AU, and raw audio
# for mp3 files use mpg321 or mpg123

# basic command for running in a loop
# while true;do aplay ~/Downloads/mixkit-office-ambience-447.wav; done;

# Check if correct number of arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <minutes>"
    exit 1
fi

N_MINUTES=$1
# Get the directory of the current script, resolving symbolic links
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# COMMAND_APLAY="aplay ${SCRIPT_DIR}/office-sounds/mixkit-office-ambience-447.wav"
COMMAND_MP3="mpg123 ${SCRIPT_DIR}/office-sounds/office-bank-keyboard-people.mp3"

END_TIME=$(( $(date +%s) + (N_MINUTES * 60) ))

echo "Repeating command for $N_MINUTES minutes: $COMMAND_MP3"

while [ $(date +%s) -lt "$END_TIME" ]; do
    eval "$COMMAND_MP3"
    sleep 3 # Sleep for a short interval (e.g., 10 seconds) before checking time again
done

echo "Script finished after $N_MINUTES minutes."
