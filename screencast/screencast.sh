#!/bin/bash
##################################################
# A quick utility to create a screencast.        #
# For more features use avconv or ffmpeg directly#
##################################################

#!/bin/sh
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
#echo "${scrcastHome}"
name="sc-`date +'%m%d%Y%-H%M%S'`"
#echo "Enter the output file name: "; read name
echo "output file ${scrcastHome}/${name}"
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
#avconv -f video4linux2 -s 5x5 -i /dev/video0 ${selfieVideo} > /dev/null 2>&1 &
avconv -f video4linux2 -s 10x10 -r 60 -i /dev/video0 -vf "unsharp=luma_msize_x=7:luma_msize_y=7:luma_amount=2.5" -codec:v libx264 -vprofile main ${selfieVideo} > /dev/null 2>&1 &
selfie_pid=$_
echo "started the selfie(${selfie_pid}). . ."

#start screencast
echo "start the screecast grab. . ." 
#lossless_ultrafast="-crf 0 no-8x8dct aq-mode 0 b-adapt 0 bframes 0 no-cabac no-debloc no-mbtre me d no-mixed-refs partitions none ref 1 scenecut 0 subme  trellis no-weightb weightp 0"
#avconv -f alsa -i pulse -f x11grab -r 24 -s $fullscreen -vf "yadif" -b:v 6144k -i :0.0 -vcodec libx264 -preset slow -threads 5 -y ${interimName}
#ffmpeg -f x11grab -s SZ -r 30 -i :0.0 -qscale 0 -vcodec huffyuv grab.avi
avconv -f alsa -i pulse -f x11grab -r 5 -s $fullscreen -same_quant -i :0.0 -vcodec libx264 -preset ultrafast -threads 4 -y ${interimName}
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
avconv -i ${onlyAudioCleaned} -i ${onlyVideo} -same_quant -y ${mergedClean}
echo "noise cancellation applied and merged. . ." 

#merge the selfie
avconv -same_quant -i ${mergedClean} -vf "movie=${selfieVideo}[inner];[in][inner] overlay=main_w-overlay_w-10:main_h-overlay_h-10 [out]" -y ${mergedSelfieVideo}
echo "selfie merged"

#add watermark
avconv -same_quant -i ${mergedSelfieVideo} -vf "movie=${watermark} [watermark];[in][watermark] overlay=main_w-overlay_w-15:main_h-overlay_h-600 [out]" -y ${finalName}
echo "watermark merged"

#cleanup
rm -rf "${scrcastHome}/tmp"
