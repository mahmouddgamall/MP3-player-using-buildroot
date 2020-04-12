#!/bin/bash



if [ ! -e /sys/class/gpio/gpio23 ] ;
then

echo "23" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio23/direction

fi

if [ ! -e /sys/class/gpio/gpio22 ] ;
then

echo "22" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio22/direction

fi

if [ ! -e /sys/class/gpio/gpio27 ] ;
then

echo "27" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio27/direction

fi

if [ ! -e /sys/class/gpio/gpio17 ] ;
then

echo "17" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio17/direction

fi
