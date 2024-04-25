# Set Default vars
default_backup_remote="backup"
default_source_dir=$HOME
default_dest_dir="/latest"
default_backup_dir="/old"
default_filter_file="$HOME/.backup/filter.conf"
default_log_dir="$HOME/.backup/logs"
default_share="/$USER"

config_dir="$HOME/.backup/config"

# Get new params
while getopts ghr:s:d:b:f:l:a:c: flag
do
  case "${flag}" in
    h) help=true;;
    r) i_backup_remote=${OPTARG};;
    s) i_source_dir=${OPTARG};;
    d) i_dest_dir=${OPTARG};;
    b) i_backup_dir=${OPTARG};;
    f) i_filter_file=${OPTARG};;
    l) i_log_dir=${OPTARG};;
    a) i_share=${OPTARG};;
    c) i_config=${OPTARG};;
    g) get=true;;
  esac
done

# Help menu
if [[ $help == true ]]; then
  echo "Help Menu
---------
-h     Display this menu
-r     Set backup remote (default: $default_backup_remote)
-s     Set source directory (default: $default_source_dir)
-d     Set destination directory (default: $default_dest_dir)
-b     Set backup directory (default: $default_backup_dir)
-f     Set filter file (default: $default_filter_file)
-l     Set log file (default: $default_log_dir)
-a     Set share on remote (default: $default_share)
-c     Set or create a new config
-g     Get all configs
  "
  exit 0
fi

# Get configs
if [[ $get == true ]]; then
  echo "Existing configs:"
  echo "-----------------"
  ls -1 $config_dir
  exit 0
fi

# Check if config exist
if [[ -v i_config ]]; then
  config_file=$config_dir/$i_config 
  if [[ ! -f $config_file ]]; then
    mkdir -p $config_dir
    config_exists="false"
    touch $config_file
  else
    config_exists="true"
    source $config_file
  fi
fi

# Set default vars if not set via input
if [[ -v i_backup_remote ]]; then
  backup_remote=$i_backup_remote
else
  if [[ ! -v backup_remote ]]; then
    backup_remote=$default_backup_remote
  fi
fi
if [[ -v i_source_dir ]]; then
  source_dir=$i_source_dir
else
  if [[ ! -v source_dir ]]; then
    source_dir=$default_source_dir
  fi
fi
if [[ -v i_dest_dir ]]; then
  dest_dir=$i_dest_dir
else
  if [[ ! -v dest_dir ]]; then
    dest_dir=$default_dest_dir
  fi
fi
if [[ -v i_backup_dir ]]; then
  backup_dir=$i_backup_dir
else
  if [[ ! -v backup_dir ]]; then
    backup_dir=$default_backup_dir
  fi
fi
if [[ -v i_filter_file ]]; then
  filter_file=$i_filter_file
else
  if [[ ! -v filter_file ]]; then
    filter_file=$default_filter_file
  fi
fi
if [[ -v i_log_dir ]]; then
  log_dir=$i_log_dir
else
  if [[ ! -v log_dir ]]; then
    log_dir=$default_log_dir
  fi
fi
if [[ -v i_share ]]; then
  share=$i_share
else
  if [[ ! -v share ]]; then
    share=$default_share
  fi
fi

# Check if files and folders exits
if [[ ! -f $filter_file ]]; then
  mkdir -p "${filter_file%/*}"
  touch $filter_file
fi
if [[ ! -d $log_dir ]]; then 
  mkdir -p $log_dir
fi

# Output config
echo "Remote: $backup_remote"
echo "Source: $source_dir"
echo "Share: $share"
echo "Destination: $dest_dir"
echo "Backup Directory: $backup_dir"
echo "Filter File: $filter_file"
echo "Log Directory: $log_dir"
echo ""
echo -n "Is this config right? (yes/no): "
read check 

# Check if config is right
if [[ $check != "yes" ]]; then
  exit 0
fi

if [[ $config_exists == "true" ]]; then
  echo "Writing config..."
  sed -i -E "s|backup_remote=.*|backup_remote=$backup_remote|g" $config_file
  sed -i -E "s|source_dir=.*|source_dir=$source_dir|g" $config_file
  sed -i -E "s|dest_dir=.*|dest_dir=$dest_dir|g" $config_file
  sed -i -E "s|backup_dir=.*|backup_dir=$backup_dir|g" $config_file
  sed -i -E "s|filter_file=.*|filter_file=$filter_file|g" $config_file
  sed -i -E "s|log_dir=.*|log_dir=$log_dir|g" $config_file
  sed -i -E "s|share=.*|share=$share|g" $config_file
elif [[ $config_exists == "false" ]]; then
  echo "Writing config..."
  echo "backup_remote=$backup_remote" >> $config_file
  echo "source_dir=$source_dir" >> $config_file
  echo "share=$share" >> $config_file
  echo "dest_dir=$dest_dir" >> $config_file
  echo "backup_dir=$backup_dir" >> $config_file
  echo "filter_file=$filter_file" >> $config_file
  echo "log_dir=$log_dir" >> $config_file
fi

if ! rclone listremotes | grep -q $backup_remote: ; then
  rclone config create $backup_remote smb
  rclone config update $backup_remote --all
fi

echo "Starting backup..."

rclone sync $source_dir $backup_remote:$share$dest_dir --backup-dir $backup_remote:$share$backup_dir/$(date +%Y-%m-%d) -P --delete-excluded --filter-from $filter_file --transfers=30 --links --skip-links --checkers 30 --ignore-size --log-file=$log_dir/$i_config-$(date +%Y-%m-%d).log --stats-log-level NOTICE --color ALWAYS
