#!/bin/bash

prev_state=0
noOfPartitions=0
while true; do
        partitions="$(fdisk -l /dev/sd* | grep -v 'Unknown' | grep -v 'Empty'  | awk '/^\/dev\/sd/ {print $1}' )"
        for partition in $partitions;
          do
          toBeMounted="/media/$(basename $partition)"
          mkdir -p $toBeMounted
          mount $partition $toBeMounted
        done
        for umountPartion in $partitions;
                do
                        toBeUnmounted="/media/$(basename $umountPartion)"
                        check=`ls $toBeUnmounted | wc -l`
                        if [[ $check == '0' ]]
                                then
                                umount $toBeUnmounted
                                rm -r $toBeUnmounted
                        fi
                done

        if [[ ${partitions[0]} == `fdisk: can\'t open \'/dev/sd*\': No such file or directory` ]]
        then
                noOfPartitions=0

        else
        noOfPartitions=${#partitions[@]}
        fi
        if [[ $noOfPartitions -eq prev_state ]]
        then
               :
        #do nothing
        else
        echo 1 > /Player/device_detected
            if [[ $noOfPartitions -gt prev_state ]]
            then
                    aplay /Player/addedDevice.wav
                    echo "Device added"
            else
                    aplay /Player/removedDevice.wav
                    echo "Device removed"

            fi
        fi

        prev_state=$noOfPartitions  

done

