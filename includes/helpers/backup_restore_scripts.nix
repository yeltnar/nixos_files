{ unit_id } :
let
  backup_env_file = "/home/drew/.config/${unit_id}/backup.env";
  backup_script = ''
    source ${backup_env_file}

    if [ -z "$WORKDIR" ]; then
      echo "WORKDIR is undefined... exiting";
      exit;
    fi
    if [ -n "$SRC_DIR" ]; then
      echo "\$SRC_DIR is replaced with \$FILES_TO_BACKUP... exiting";
      exit;
    fi
    if [ -z "$BORG_REPO" ]; then
      echo "BORG_REPO is undefined... exiting";
      exit;
    fi
    if [ -z "$BORG_PASSPHRASE" ]; then
      echo "BORG_PASSPHRASE is undefined... exiting";
      exit;
    fi
    if [ -z "$ENCRYPTION" ]; then
      echo "ENCRYPTION is undefined... exiting";
      exit;
    fi

    cd "$WORKDIR";

    info_exit_code=$(borg info $BORG_REPO >& /dev/null; echo $?)

    if [ $info_exit_code -gt 0 ]; then
      echo "repo does not exsist; creating now";
      borg init $BORG_REPO --encryption=$ENCRYPTION
    fi

    echo "FILES_TO_BACKUP is $FILES_TO_BACKUP";

    if [ -z "$FILES_TO_BACKUP" ]; then
      echo "\$FILES_TO_BACKUP is empty... backing up everything";
    else
      echo "backing up $FILES_TO_BACKUP";
    fi

    # if FILES_TO_BACKUP is empty, it will backup everything 
    borg create --stats --progress --compression lz4 ::{user}-{now} $FILES_TO_BACKUP

    borg prune -v --list --keep-within=1d --keep-daily=7 --keep-weekly="5" --keep-monthly="12" --keep-yearly="2"
  '';
  restore_script = ''
    export RESTORE_DIR="/home/drew/playin/${unit_id}"
    source ${backup_env_file}

    if [ -z "$RESTORE_DIR" ]; then
      echo "RESTORE_DIR is undefined... exiting";
      exit;
    fi

    if [ -z "$WORKDIR" ]; then
      echo "WORKDIR is undefined... exiting";
      exit;
    fi
    if [ -n "$SRC_DIR" ]; then
      echo "\$SRC_DIR is replaced with \$FILES_TO_BACKUP... exiting";
      exit;
    fi
    if [ -z "$BORG_REPO" ]; then
      echo "BORG_REPO is undefined... exiting";
      exit;
    fi
    if [ -z "$BORG_PASSPHRASE" ]; then
      echo "BORG_PASSPHRASE is undefined... exiting";
      exit;
    fi
    if [ -z "$ENCRYPTION" ]; then
      echo "ENCRYPTION is undefined... exiting";
      exit;
    fi

    cd "$WORKDIR";

    borg info $BORG_REPO >& /dev/null
    info_exit_code=$?;

    if [ $info_exit_code -gt 0 ]; then
      echo "repo does not exsist; exiting";
      exit 1;
    fi

    archive_name=$(borg list --sort-by timestamp --last 1 --format "{archive}")
    echo $archive_name

    # borg extract user@host:path/to/repo_directory::Monday path/to/target_directory --exclude '*.ext'

    echo "restoring"
    borg list "$BORG_REPO::$archive_name"

    cd $RESTORE_DIR

    borg extract "$BORG_REPO::$archive_name"
  '';
in {
  backup_script = backup_script;
  restore_script = restore_script;
  backup_env_file = backup_env_file;
}
