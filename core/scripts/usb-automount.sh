#!/bin/bash

ACTION=$1
DEVBASE=$2
DEVICE="/dev/${DEVBASE}"
USB_LOG="/sabu/logs/endpoint/usb.log"
MOUNT_POINT="/mnt/usb"
CHECK_MOUNT_POINT=$(/bin/mount | /bin/grep ${DEVICE} | /usr/bin/awk '{ print $3 }')
DATE=$(date +"[%Y-%m-%d %H:%M:%S]")
CHECK_UID=$(id sabu | awk {'print $1'} | cut -d'=' -f2 | cut -d'(' -f1)
CHECK_GID=$(id sabu | awk {'print $2'} | cut -d'=' -f2 | cut -d'(' -f1)

# MOUNT KEY
mount_key()
{
    # CHECK IF MOUNT
    if [[ -n ${CHECK_MOUNT_POINT} ]] 
    then
        exit 1
    fi

    # GET INFO DRIVE: $ID_FS_LABEL, $ID_FS_UUID, and $ID_FS_TYPE
    eval $(/sbin/blkid -o udev ${DEVICE})
    LABEL=${ID_FS_LABEL}
    
    if [[ -z "${LABEL}" ]]
    then
        LABEL=${DEVBASE}
    
    elif /bin/grep -q "${MOUNT_POINT}" /etc/mtab 
    then
        LABEL+="-${DEVBASE}"
    fi

    # GLOBAL
    OPTS="rw,relatime,nosuid,nodev,noexec,gid=${CHECK_GID},uid=${CHECK_UID}"

    # MOUNT
    /bin/mount -o ${OPTS} ${DEVICE} ${MOUNT_POINT}

    # LOG ACTION
    echo "$DATE [USB][Mount] USB key mounted in '/mnt/usb'" >> $USB_LOG
}

# UNMOUNT KEY
unmount_key()
{
    if [[ -n ${MOUNT_POINT} ]] 
    then
        # UNMOUNT
        /bin/umount -l ${MOUNT_POINT}

        # LOG ACTION
        echo "$DATE [USB][Mount] USB key unmounted in '/mnt/usb'" >> $USB_LOG
    fi
}

# MAIN
echo "$DATE [USB][Detect] USB key detected" >> $USB_LOG
case "${ACTION}" in

    add)
        mount_key
        ;;

    remove)
        unmount_key
        ;;
esac
