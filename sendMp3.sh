#! /bin/bash
token={botToken}
chat_id={chat_id}
channelName="{channelName}"
rm -rf tosend
mkdir tosend
thisAlbum=""
sendAlbumName() {
  curl "https://api.telegram.org/bot$token/sendMessage?chat_id=$chat_id&text=Album: $album"
}
for i in *.mp3
do
        fileInfo=$(eyeD3 "$i" 2>/dev/null)
        title=$(echo "$fileInfo"|grep -e ^title|cut -d":" -f2-10|cut -d" " -f2-10)
        album=$(echo "$fileInfo"|grep -e ^album:|cut -d":" -f2-10|cut -d" " -f2-10)
        year=$(date -d $(echo "$fileInfo"|grep "recording date"|cut -d":" -f2-100|tr -d " ") '+%Y')
        track=$(echo "$fileInfo"|grep track|tr "\t" " "|cut -d" " -f2)
        track2=$(echo $track|cut -d"/" -f1)
        if [ $track2 -lt 10 ]
                then
                        track2=0$track2
        fi
        cp "$i" tosend/"$year"_"$album"_"$track2"_"$title".mp3
done
cd tosend
for i in *.mp3
do
	echo $i
	fileInfo=$(eyeD3 "$i" 2>/dev/null)
        title=$(echo "$fileInfo"|grep -e ^title|cut -d":" -f2-10|cut -d" " -f2-10)
        album=$(echo "$fileInfo"|grep -e ^album:|cut -d":" -f2-10|cut -d" " -f2-10)
        echo $album
        if [ "$thisAlbum" != "$album" ]; then
                sendAlbumName;
                echo "New Album: $album"
                thisAlbum=$album
        fi

        time=$(echo "$fileInfo"|grep "Time:"|tr "\t" " "|cut -d" " -f2)
        year=$(date -d $(echo "$fileInfo"|grep "recording date"|cut -d":" -f2-100|tr -d " ") '+%Y')
        track=$(echo "$fileInfo"|grep track|tr "\t" " "|cut -d" " -f2)
        track2=$(echo $track|cut -d"/" -f1)
        if [ $track2 -lt 10 ]
                then
                        track2=0$track2
        fi
        Bitrate=$(echo "$fileInfo"|grep "Time:"|tr "\t" " "|cut -d"[" -f2|cut -d"]" -f1)
        genre=$(echo "$fileInfo"|grep "genre"|tr "\t" " "|cut -d":" -f3|cut -d"(" -f1)
        artist=$(echo "$fileInfo"|grep -e ^artist:|cut -d":" -f2-10|cut -d" " -f2-10)
        size=$(du -h "$i" |tr "\t" " " |cut -d" " -f1)
        tags="Title: $title\nSize: $size\nAlbum: $album\nArtist: $artist\nTime: $time\nYear: $year\nTrack: $track\nBitrate:$Bitrate\nGenre:$genre\n$channelName"
        tags2=`echo -e $tags`
        #echo "$tags2"
        curl -F "chat_id=$chat_id" -F audio=@"./$i" https://api.telegram.org/bot$token/sendAudio -F caption="$tags2"
        #echo -e "$tags"
        
done


