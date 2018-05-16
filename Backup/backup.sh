#! /bin/bash

set -e;

# get date and time of backup
DATE=`date +%a_%d_%m_%g_%H_%M_%S_%Z`

# define base dir
BASE_DIR="/home/user/";

LOCAL_BACKUP_DIR="${BASE_DIR}backup/";

NEW_BACKUP_DIR="${LOCAL_BACKUP_DIR}${DATE}/"

# store paths to be taken for backup
# relative to base dir
dirs=("dir1" "somewhere/dir2");

# prepend BASE_DIR to each element
dirs=("${dirs[@]/#/$BASE_DIR}");

# colors
RED='\033[0;31m';
BLUE='\033[0;34m';
GREEN='\033[0;32m';
NC='\033[0m';

USERNAME="nobody"
SERVER_IP="192.168.0.1"
REMOTE_BACKUP_PATH="/tmp/backup/"

info() {
  printf "${BLUE}[   INFO   ] ${NC}$1 \n";
}

success() {
  printf "${GREEN}[  SUCCESS ] ${NC}$1 \n";
}

complete() {
  printf "${GREEN}[ COMPLETE ] ${NC}$1 \n";
}

error() {
  printf "${RED}[  ERROR  ] ${NC}$1 \n";
}

quit() {
  printf "${RED}[  EXITED ]\n";
  exit 1
}

check_if_host_is_up() {
  status=$(ping -q -w 1 -c 1 $1 > /dev/null && echo "ok" || echo "error");

  if [[ $status =~ "ok" ]]; then
    success "$1 is up"
  else
    error "Cannot establish a stable internet connection.";
    quit
  fi
}

initiate_local_backup() {
  for i in "${dirs[@]}"
  do
    rsync -aqz $i $NEW_BACKUP_DIR;
  done

  success "Saved to local backup"
}

continue_remote_backup() {
  info "Saving backup to remote server"

  status=$(rsync -azq $LOCAL_BACKUP_DIR "${USERNAME}@${SERVER_IP}:${REMOTE_BACKUP_PATH}")

  success "Saved backup to remote server"
  complete "Completed backup procedure"
}

initiate_remote_backup() {
  check_if_host_is_up $(ip r | grep "default" | cut -d ' ' -f 3)

  info "Checking if server is up"

  check_if_host_is_up $SERVER_IP;

  continue_remote_backup;
}

info "Starting backup procedure"

if [ ! -d "$LOCAL_BACKUP_DIR" ]; then
  success "Created a local backup directory";
  mkdir -p $LOCAL_BACKUP_DIR;
fi

mkdir -p $NEW_BACKUP_DIR

info "Created backup directory: ${NEW_BACKUP_DIR}"

info "Saving to local backup directory";

initiate_local_backup;

initiate_remote_backup;
