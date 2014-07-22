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
. $(scriptPath)/screencast.conf
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
watermark="./pramati.png"

fullscreen=$(xwininfo -root | grep 'geometry' | awk '{print $2;}')
echo "selfie= ${selfie}"
echo "video= ${video_dev}"
if [ $selfie -eq 1 ]
then
    #get the selfie video
    avconv -f video4linux2 -s 5x5 -r 5 -i $video_dev -vf "unsharp=luma_msize_x=7:luma_msize_y=7:luma_amount=2.5" -codec:v libx264 -preset ultrafast -threads 4 -y ${selfieVideo} > /dev/null 2>&1 &
    selfie_pid=$_
    echo "started the selfie(${selfie_pid}). . ."
fi

#start screencast
echo "start the screecast grab. . ." 
avconv -f alsa -i pulse -f x11grab -r 5 -s $fullscreen -same_quant -i :0.0 -vcodec libx264 -preset ultrafast -threads 4 -y ${interimName}
echo "screecast grab ended."
kill ${selfie_pid}
echo "selfie killed"

#split audio and video
avconv -i ${interimName} -same_quant -an ${onlyVideo}
avconv -i ${interimName} -same_quant ${onlyAudio}
echo "audio video splited. . ."

#cancel out the noise
sox ${onlyAudio} ${onlyAudioCleaned} noisered noise.prof 0.21

###TODO: merge all in 1 step
if [ $selfie -eq 1 ]
then
  avconv \
     -same_quant -i ${onlyAudioCleaned} \
     -same_quant -i ${onlyVideo} \
      -vf "movie=${selfieVideo} [selfie]; [in][selfie] overlay=main_w-overlay_w-10:main_h-overlay_h-10 [T1]; movie=${watermark} [watermark];[T1][watermark] overlay=main_w-overlay_w-15:main_h-overlay_h-600 [out]" -y ${finalName}
else
    echo "Not Implemented Yet."
fi


#merge back the cleaned audio
#avconv -i ${onlyAudioCleaned} -i ${onlyVideo} -same_quant -y ${mergedClean}
#echo "noise cancellation applied and merged. . ." 

#if [ $selfie -eq 1]
#then
   #merge the selfie
   #avconv -same_quant -i ${mergedClean} -vf "movie=${selfieVideo}[inner];[in][inner] overlay=main_w-overlay_w-10:main_h-overlay_h-10 [out]" -y ${mergedSelfieVideo}
   #echo "selfie merged"
#fi

#add watermark
#avconv -same_quant -i ${mergedSelfieVideo} -vf "movie=${watermark} [watermark];[in][watermark] overlay=main_w-overlay_w-15:main_h-overlay_h-600 [out]" -y ${finalName}
#echo "watermark merged"

#cleanup
rm -rf "${scrcastHome}/tmp"
