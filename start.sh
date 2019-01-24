#!/bin/bash
#set -e
if [ "$1" = "monitor" ] ; then
  if [ -n "$TRACKER_SERVER" ] ; then  
    sed -i "s|^tracker_server=.*$|#tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/client.conf
	userDefineTrackerServer="$TRACKER_SERVER"    #like this 10.1.1.12:22122,10.1.1.12:22122
	array1=(${userDefineTrackerServer//,/ }) 
	for var1 in ${array1[@]}
	do
	  echo "" >> /etc/fdfs/client.conf
      echo tracker_server=$var1 >> /etc/fdfs/client.conf
	done
  fi
  fdfs_monitor /etc/fdfs/client.conf
  exit 0
elif [ "$1" = "storage" ] ; then
  FASTDFS_MODE="storage"
else 
  FASTDFS_MODE="tracker"
fi

if [ -n "$PORT" ] ; then  
  sed -i "s|^port=.*$|port=${PORT}|g" /etc/fdfs/"$FASTDFS_MODE".conf
  if [ "$1" = "storage" ] ; then  
    sed -i "s|^storage_server_port=.*$|storage_server_port=${PORT}|g" /etc/fdfs/mod_fastdfs.conf
  fi
fi

if [ -n "$HTTP_SERVER_PORT" ] ; then  
  sed -i "s|^http.server_port=.*$|http.server_port=${HTTP_SERVER_PORT}|g" /etc/fdfs/"$FASTDFS_MODE".conf
  if [ "$1" = "storage" ] ; then  
	sed -i "s|listen .*;.*$|listen ${HTTP_SERVER_PORT};|g" /etc/fdfs/nginx.conf
  fi
fi

if [ -n "$TRACKER_SERVER" ] ; then  
  sed -i "s|^tracker_server=.*$|#tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/storage.conf
  sed -i "s|^tracker_server=.*$|#tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/client.conf
  sed -i "s|^tracker_server=.*$|#tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/mod_fastdfs.conf
  userDefineTrackerServer="$TRACKER_SERVER"    #like this 10.1.1.12:22122,10.1.1.12:22122
  array2=(${userDefineTrackerServer//,/ }) 
  for var2 in ${array2[@]}
  do
   echo "" >> /etc/fdfs/storage.conf
   echo tracker_server=$var2 >> /etc/fdfs/storage.conf
   echo "" >> /etc/fdfs/client.conf
   echo tracker_server=$var2 >> /etc/fdfs/client.conf
   echo "" >> /etc/fdfs/mod_fastdfs.conf
   echo tracker_server=$var2 >> /etc/fdfs/mod_fastdfs.conf
  done
fi

if [ -n "$GROUP_NAME" ] ; then  
  sed -i "s|group_name=.*$|group_name=${GROUP_NAME}|g" /etc/fdfs/storage.conf
  sed -i "s|group_name=.*$|group_name=${GROUP_NAME}|g" /etc/fdfs/mod_fastdfs.conf
fi 

FASTDFS_LOG_FILE="${FASTDFS_BASE_PATH}/logs/${FASTDFS_MODE}d.log"
PID_NUMBER="${FASTDFS_BASE_PATH}/data/fdfs_${FASTDFS_MODE}d.pid"

echo "try to start the $FASTDFS_MODE node..."
if [ -f "$FASTDFS_LOG_FILE" ]; then 
	rm "$FASTDFS_LOG_FILE"
fi
# start the fastdfs node.	
fdfs_${FASTDFS_MODE}d /etc/fdfs/${FASTDFS_MODE}.conf start
if [ "$1" = "storage" ] ; then  
	/usr/local/nginx/sbin/nginx -c /etc/fdfs/nginx.conf
fi

# wait for pid file(important!),the max start time is 5 seconds,if the pid number does not appear in 5 seconds,start failed.
TIMES=5
while [ ! -f "$PID_NUMBER" -a $TIMES -gt 0 ]
do
    sleep 1s
	TIMES=`expr $TIMES - 1`
done

# if the storage node start successfully, print the started time.
# if [ $TIMES -gt 0 ]; then
#     echo "the ${FASTDFS_MODE} node started successfully at $(date +%Y-%m-%d_%H:%M)"
	
# 	# give the detail log address
#     echo "please have a look at the log detail at $FASTDFS_LOG_FILE"

#     # leave balnk lines to differ from next log.
#     echo
#     echo

    
	
# 	# make the container have foreground process(primary commond!)
#     tail -F --pid=`cat $PID_NUMBER` /dev/null
# # else print the error.
# else
#     echo "the ${FASTDFS_MODE} node started failed at $(date +%Y-%m-%d_%H:%M)"
# 	echo "please have a look at the log detail at $FASTDFS_LOG_FILE"
# 	echo
#     echo
# fi
tail -f "$FASTDFS_LOG_FILE"
