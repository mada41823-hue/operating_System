source ./lib.sh
TARGET_DIR=${1:-../sample_data}
require_dir
scan_directory(){

local f
local files_count=0
local folders_count=0

for f in "$TARGET_DIR"/*
do
if [ -f "$f" ]; then
echo "File: $f"
files_count=$((files_count + 1))
elif [ -d "$f" ]; then
echo "Folder: $f"
folders_count=$((folders_count + 1))
fi
done

echo "Files: $files_count"
echo "Folders: $folders_count"
log_action "scan_directory"
}
#show File permission
permission_audit(){

local f
local permissions
local unreadable_count=0
local excutable_count=0

for f in "$TARGET_DIR"/*
do
if [ -f "$f" ]; then
permissions=""
if [ -r "$f" ];then
permissions="${permissions}r"
else
permissions="${permissions}-"
unreadable_count=$((unreadable_count + 1))
fi

if [ -w "$f" ]; then
permissions="${permissions}w"
else
permissions="${permissions}-"
fi

if [ -x "$f" ]; then
permissions="${permissions}x"
excutable_count=$((excutable_count + 1))
else
permissions="${permissions}-"
fi

echo "$permissions $f"
fi
done

echo "Unreadable files: $unreadable_count"
echo "Executable files: $excutable_count"
log_action "Permission_audio"
}

extension_report(){

local f
local file_name
local extension

declare -A extension_count

extension_count[txt]=0
extension_count[log]=0
extension_count[sh]=0
extension_count[jpg]=0
extension_count[other]=0

for f in "$TARGET_DIR"/*
do
if [ -f "$f" ]; then
file_name="${f##*/}"
extension="${file_name##*.}"

if [ "$file_name" = "$extension" ]; then
extension="other"
fi

if [ "$extension" = "txt" ]; then
extension_count[txt]=$((extension_count[txt] + 1))
elif [ "$extension" = "log" ];
then
extension_count[log]=$((extension_count[log] + 1))
elif [ "$extension" = "sh" ]; then
extension_count[sh]=$((extension_count[sh] + 1))
elif [ "$extension" = "jpg" ]; then
extension_count[jpg]=$((extension_count[jpg] + 1))
else
extension_count[other]=$((extension_count[other] + 1))
fi
fi
done

echo "txt: ${extension_count[txt]}"
echo "log: ${extension_count[log]}"
echo "Sh: ${extension_count[sh]}"
echo "jpg: ${extension_count[jpg]}"
echo "other: ${extension_count[other]}"
log_action "extension_report"
}
search_file(){

local f  
local search_text
local found=0

echo "PLease Enter  text to Search:"
read search_text

for f in "$TARGET_DIR"/*
do 
if [ -f "$f" ]; then
if echo "$f" | grep -q "$search_text"; then
echo "$f"
 found=1
fi
fi
done

if [ "$found" -eq 0 ]; then
echo "No matching filed Found."
fi
log_action "search_file"
}

backup_all(){

local f
local saved=0
local skipped=0

mkdir -p "$TARGET_DIR/backups"

for f in "$TARGET_DIR"/*
do
if [ -f "$f" ]; then
if [ -r "$f" ]; then
if cp "$f" "$TARGET_DIR/backups/$(basename "$f")_$(date +%Y%m%d_%H%M%S).bak"; then
saved=$((saved + 1))
else
skipped=$((skipped + 1))
fi
else
skipped=$((skipped + 1))
echo "File skipped: $f"
fi
fi
done

echo "Saved: $saved"
echo "Skipped: $skipped"
log_action "Backup"
}

list_backups(){
local f
local found=0

for f in "$TARGET_DIR"/backups/*
 do
if [ -f "$f" ]; then
echo "$(basename "$f")"
 found=1
fi
done
if [ "$found" -eq 0 ]; then
echo "No backup  yet"
fi
log_action "list_Backup"
}
# Restore a selected backup file.
restore_backup() {
 local name
 echo "Please Enter Backup name:"
 read name

 if [ -f "$TARGET_DIR/backups/$name" ]; then
 if [ -e "$TARGET_DIR/restored_$name" ]; then
 echo "Restored file already exists."
 else
 if cp "$TARGET_DIR/backups/$name" "$TARGET_DIR/restored_$name"; then
 echo "Backup restored."
 else
 echo "Restore failed."
 fi
 fi
  else
 echo "Backup not Found"
 fi
    log_action "restore_backup"
}





#Show Menu
menu(){

local choice
 
while true
do 
echo "================================================"
echo "                   FILD AUDITOR:"
echo "================================================"
echo "1. Scan Directory"
echo "2. Permission AUdio"
echo "3. EXtension Report"
echo "4. Search File"
echo "5.Backup All"
echo "6. List Backup All"
echo "7. Restore Backup"
echo "8. Exit"
read -p "choose:  " choice
case $choice in
1) scan_directory ;;
2) permission_audit ;;
3) extension_report ;;
4)search_file ;;
5)backup_all ;;
6)list_backups ;;
7)restore_backup ;;
8) break ;;
*)log_error "Wrong choice" ;; esac
done
}
 
ACTION=$2
if [ -z "$ACTION" ]; then
menu
elif [ "$ACTION" = "scan" ]; then
scan_directory
elif [ "$ACTION" = "perms" ]; then
permission_audit
elif [ "$ACTION" = "ext" ];then
extension_report
elif [ "$ACTION" = "backup" ]; then
backup_all
else
log_error "Invalid_Action"
fi
