#!/bin/bash


/*
Automate SnapShot Creation Script

This script will create snapshot backup of AWS EBS Volume on daily basis
You have to provide -
  Volume ID of which you want to make backup (you can provide array too) 
  Instance Id
  your aws authorization certificate and key for authentication.
  DELETE_OLDER_THAN ( number of days you want to delete snapshots older than that value) 

*/

export EC2_HOME=/ebs/tools/ec2-api-tools-1.6.13.0  # Make sure you use the API tools, not the AMI tools
export EC2_BIN=$EC2_HOME/bin
export PATH 0:$EC2_BIN
export JAVA_HOME=/usr/local/java/jre1.7.0_75  # have to edit ec2-cmd file to disable java environment check


EC2_BIN=$EC2_HOME/bin
# store the certificates and private key to your amazon account
MY_CERT='/path to pem file.pem'
MY_KEY='/path to pem file.pem'
MY_INSTANCE_ID='i-something' #id of instances of which you wanna take snapshot,can supply more than one.
VOLUMES="vol-something"  #id of volumes of which you wanna take snapshot, can supply more than one also 
TAG="Testing Tag"   #tag to add with snapshot description
DELETE_OLDER_THAN=2
sync
#create the snapshots
echo "Create EBS Volume Snapshot - Process started at $(date +%m-%d-%Y-%T)"
echo ""
echo $VOLUME_LIST
for volume in $(echo $VOLUMES); do
   NAME="BySnapShotScript-"$volume
   DESC=$NAME-$(date +%m-%d-%Y)$TAG
   echo "Creating Snapshot for the volume: $volume with description: $DESC"
   echo "Snapshot info below:"
   $EC2_BIN/ec2-create-snapshot -C $MY_CERT -K $MY_KEY -d $DESC $volume 
   echo ""
done
# tmp file
TMP_FILE2='/tmp/snap-shot-info.txt'

sync
#delete the snapshot
for volume in $(echo $VOLUMES); do
echo "Removing EBS Volume Snapshot of volume $volume Which are $DELETE_OLDER_THAN   days old started at $(date +%m-%d-%Y-%T)"
    $EC2_BIN/ec2-describe-snapshots -C $MY_CERT -K $MY_KEY > $TMP_FILE2
    snap_shot_list=$(cat $TMP_FILE2 | grep ${volume} | awk '{ print $2","$5 }')

for snapshot in $(echo $snap_shot_list); do
         id=$( echo $snapshot | awk  -F ',' '{ print $1}')  
         createDate=$( echo $snapshot | awk  -F ',' '{ print $2}') 

         days_old=$(($(($(date -d "$(echo $current_date )" "+%s") - $(date -d "$(echo $createDate )" "+%s"))) / 86400))
         echo "SnapShot "$id" is "$days_old " Days Old"
         if [ "$days_old" -ge "$DELETE_OLDER_THAN" ]; then
            echo "Deleting SnapShot "$id;
            $EC2_BIN/ec2-delete-snapshot -C $MY_CERT -K $MY_KEY $id
         fi
       
        done
done

echo "Process ended at $(date +%m-%d-%Y-%T)" 
echo ""
rm -f $TMP_FILE2

#Script Code End Here

