#!/bin/bash

updateAllSongs()
{

    i=0
    songs=()

    while IFS= read -r var
    do 

    i=$[ $i +1 ]
    songs+=($var)

    done <<< $(find / -iname "*mp3" 2>/dev/null) 
    Max=$i
    Min=0

}


updateDevices=/Player/device_detected

currentTerminalCommand=/Player/tempFile

Mass_detected=0
Cmd_detected=0
index=0
status=0


updateAllSongs

if [ ${#songs[@]} -eq 0 ]
then

echo "No .MP3 files found"

else

madplay -Q --no-tty-control ${songs[index]} 2>/dev/null  &
currentSongProcess=$!

echo "MP3 Playing > [$(basename ${songs[index]})]"

fi

while :
do

    if [[ $( cat $updateDevices ) == '1' ]]
    then

    updateAllSongs
    echo 0 > $updateDevices

    fi



    # if user entered cmd play
    if [[ $( cat $currentTerminalCommand ) == '1' ]]
	then
        #wait for debouncing
		sleep 0.5

        #Clear the Global Variable
        echo 0 > $currentTerminalCommand

        #continue the song 
        kill -18 $currentSongProcess  
        echo "MP3 Playing > [$(basename ${songs[index]})]"

    # if user entered cmd pause
    elif [[ $( cat $currentTerminalCommand ) ==  '2' ]]
	then
        #wait for debouncing
		sleep 0.5

		#Clear the Global Variable
        echo 0 > $currentTerminalCommand

        #pasue the song 
        kill -19 $currentSongProcess 
        echo "MP3 Paused > [$(basename ${songs[index]})]"

	# if user entered cmd next
    elif [[ $( cat $currentTerminalCommand ) == '3' ]]
	then
        #wait for debouncing
		sleep 0.5

        #Clear the Global Variable
        echo 0 > $currentTerminalCommand

        #jump to the next song 
        if [ $index -eq $Max ]
		then
			index=0
		else
			index=$(($index+1))
		fi
		disown $currentSongProcess
		kill -9 $currentSongProcess 
		madplay -Q --no-tty-control ${songs[index]} 2>/dev/null  &  
		currentSongProcess=$!

		echo "MP3 Playing > [$(basename ${songs[index]})]"

	# if user entered cmd previous
	elif [[ $( cat $currentTerminalCommand ) == '4' ]]
	then
        #wait for debouncing
		sleep 0.5

        #Clear the Global Variable
        echo 0 > $currentTerminalCommand

        #jump to the previous song 
	    if [ $index -eq 0 ]
		then
			index=$(($Max -1)) 
		else
			index=$(($index-1))
		fi
		disown $currentSongProcess
		kill -9 $currentSongProcess
		madplay -Q --no-tty-control ${songs[index]} 2>/dev/null  & 
		currentSongProcess=$!

        echo "MP3 Playing > [$(basename ${songs[index]})]"

	#if user entered cmd Shuffle
	elif [[ $( cat $currentTerminalCommand ) == '5' ]]
	then
		#wait for debouncing
		sleep 0.5
		#Clear The Global Variable
		echo 0 > $currentTerminalCommand

		disown $currentSongProcess
        kill -9 $currentSongProcess
        madplay -Q --no-tty-control -z `echo ${songs[@]}` 2>/dev/null &
        currentSongProcess=$!

        echo "MP3 is Shuffling"
	


    #check Toogle Button
	elif [ $(cat /sys/class/gpio/gpio17/value) -eq 1 ]
	then
        #wait for debouncing
		sleep 0.5

        #check whether to pause or to play
		if [ $status -eq 0 ]
		then
			kill -19 $currentSongProcess 2>/dev/null
			status=1
            		echo "MP3 Paused > [$(basename ${songs[index]})]"
		else
			kill -18 $currentSongProcess 2>/dev/null
			status=0
			echo "MP3 Playing > [$(basename ${songs[index]})]"
		fi
		
    #check Next Button
	elif [ $(cat /sys/class/gpio/gpio27/value) -eq 1 ]
	then
        #wait for debouncing
		sleep 0.5

		#jump to the next song 
        	if [ $index -eq $(($Max-1)) ]
		then
			index=0
		else
			index=$(($index+1))
		fi

		disown $currentSongProcess
		kill -9 $currentSongProcess 
		madplay -Q --no-tty-control ${songs[index]} 2>/dev/null &
		currentSongProcess=$!

        	echo "MP3 Playing > [$(basename ${songs[index]})]"

    #check previous Button
	elif [ $(cat /sys/class/gpio/gpio22/value) -eq 1 ]
	then
		sleep 1
        #check if the button is still pushed after 1 second
        if [ $(cat /sys/class/gpio/gpio22/value) -eq 1 ]
        then
            #play the previous song
            if [ $index -eq 0 ]
            then
                index=$(($Max -1)) 
            else
                index=$(($index-1))
            fi

	    	disown $currentSongProcess	
            kill -9 $currentSongProcess
            madplay -Q --no-tty-control ${songs[index]} 2>/dev/null  &
            currentSongProcess=$!

            echo "MP3 Playing > [$(basename ${songs[index]})]"

        else
            #restart the currentSongProcess song
	    	disown $currentSongProcess
            kill -9 $currentSongProcess
            madplay -Q --no-tty-control ${songs[index]} 2>/dev/null  &
            currentSongProcess=$!

            echo "MP3 Playing > [$(basename ${songs[index]})]"

        fi

	elif [ $(cat /sys/class/gpio/gpio23/value) -eq 1 ]
	then
		sleep 0.5
		
		disown $currentSongProcess
		kill -9 $currentSongProcess
		madplay -Q --no-tty-control -z `echo ${songs[@]}` 2>/dev/null &
		currentSongProcess=$!

		echo "MP3 is Shuffling"

	fi

done
