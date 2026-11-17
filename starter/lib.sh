get_date(){

date "+%Y-%m-%d %H:%M:%S"
}

log_action(){

local action 
action=$1
echo "$(get_date) - $action" >> "$TARGET_DIR/auditor.log"
}

log_info(){

echo "INFO: $1"
}

log_error(){

echo "ERROR: $1"
}

require_dir(){

if [ ! -d "$TARGET_DIR" ]; then
log_error "DIRECTOERY NOT FOUND"
exit 1
fi
}

