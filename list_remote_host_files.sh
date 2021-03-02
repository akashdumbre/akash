#!/bin/bash +x
#remote hostname/servername
host=""

#username to ssh (passwordless authentication must be enabled for this user)
user=""

#parent directory for listing files e.g. /var/log/
cabinet_path=""

#flag to list filenames as well, set to no if file listing is not required.
filenameenable="yes"

#comma (,) seperated subfolders, we want to list files from, e.g. apache,yum
subfolders="apache,yum"

#maxdepth param to dig files in number of subfolders
maxdepth=5

echo -e "Search Max Depth: $maxdepth \nNote: Please change maxdepth parameter accordingly with subdirectories count"
#s=$(printf "%-30s" "*")
function join { local IFS="$1"; shift; echo "$*"; }
IFS=', ' read -r -a array <<< "$subfolders"
echo "${s// /*}"
for folder in "${array[@]}"
do

ssh -q -o StrictHostKeyChecking=no  $user@$host folder=$folder host=$host cabinet_path=$cabinet_path maxdepth=$maxdepth filenameenable=$filenameenable 'bash -s' <<'ENDSSH'
        
        dir_path=$(echo $cabinet_path$folder)
        echo -e "\nHOST: $host\nListing subfolders: $dir_path\nGetting Disk usage and Files count...\n"
        if [ -d $dir_path ]
        then
        totalfilecount=$(ls -Rlr $dir_path | grep -v '^total'  | grep '^-' | wc -l | tr -s ' ' )
        totalsize=$(find $dir_path -maxdepth 3 -type d -exec bash -c "du -sh {} | tr '\n' '\t'; ls -l {}  | grep -v '^d' | grep -v '^total' | wc -l " \; | awk '{printf "%-12s | %-70s | %-50s\n",$1,$2,$3}')
        finalsize=`du -cm $dir_path | grep -i total | awk '{print $1}'`
        echo -e "Total Size\tParent and Sub directories\t\t\t\t\tTotal Regular Files\n$totalsize\n\n------> [$folder] Total Files Count: $totalfilecount\n------> [$folder] Total Files Size : $finalsize MB\n"
        if [ $filenameenable == "yes" ]
        then
        filenames=$(find $dir_path -maxdepth 3 -type d -exec bash -c " ls -ltrh {}  | grep -v '^d' | grep -v '^total' " \; )
        echo -e "\n\nFile Names:\n$filenames"
        fi
        else
                echo "Directory NOT EXIST !!! [$dir_path]"
        fi
ENDSSH
echo "******************************************************"

done
#!/bin/bash -x
