#!/bin/bash
##################################################
# A quick utility to create a screencast.        #
# For more features use avconv or ffmpeg directly#
##################################################

#!/bin/sh
echo "Enter the output file name: "; read name

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

scrcastHome="$(scriptPath)/Videos"
echo "${scrcastHome}"
mkdir -p "${scrcastHome}/tmp"
interimName="${scrcastHome}/tmp/${name}-interim-xxyy.mp4"
mergedClean="${scrcastHome}/tmp/${name}-mergedclean-xxyy.mp4"
finalName="${scrcastHome}/${name}.mp4"
onlyAudio="${scrcastHome}/tmp/${name}-audio-xxyy.wav"
onlyVideo="${scrcastsHome}/tmp/${name}-video-xxyy.mp4"
selfieVideo="${scrcastHome}/tmp/${name}-selfie-xxyy.mp4"
onlyAudioCleaned="${scrcastsHome}/tmp/${name}-audio-cleaned-xxyy.wav"
mergedSelfieVideo="${scrcastHome}/tmp/${name}-mergedselfie-xxyy.mp4"
watermark="pramati.png"

fullscreen=$(xwininfo -root | grep 'geometry' | awk '{print $2;}')
#get the selfie video
avconv -f video4linux2 -s 5x5 -i /dev/video0 ${selfieVideo} > /dev/null 2>&1 &
selfie_pid=$_
echo "started the selfie(${selfie_pid}). . ."

#start screencast
echo "start the screecast grab. . ." 
avconv -f alsa -i pulse -f x11grab -r 30 -s $fullscreen -i :0.0 -vcodec libx264 -preset ultrafast -threads 4 -y ${interimName}
echo "screecast grab ended."
kill ${selfie_pid}
echo "selfie killed"

#split audio and video
avconv -i ${interimName} -same_quant -an ${onlyVideo}
avconv -i ${interimName} -same_quant ${onlyAudio}
echo "audio video splited. . ."

#cancell out the noise
sox ${onlyAudio} ${onlyAudioCleaned} noisered noise.prof 0.21

#merge back the cleaned audio
avconv -i ${onlyAudioCleaned} -i ${onlyVideo} -same_quant ${mergedClean}
echo "noise cancellation applied and merged. . ." 

#merge the selfie
avconv -i ${mergedClean} -vf "movie=${selfieVideo}[inner];[in][inner] overlay=main_w-overlay_w-10:main_h-overlay_h-10 [out]" ${mergedSelfieVideo}
echo "selfie merged"

#add watermark
avconv -i ${mergedSelfieVideo} -vf "movie=${watermark} [watermark];[in][watermark] overlay=main_w-overlay_w-15:main_h-overlay_h-600 [out]" ${finalName}
echo "watermark merged"

#cleanup
rm -rf "${scrcastHome}/tmp"
