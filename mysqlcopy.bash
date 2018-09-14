#!/usr/bin/env bash

# Exit on failure, or if calling an unset variable
set -eu

# I literally just copied this shit off the internet, because it works
while getopts ":d:u:f:t:" opt; do
    case $opt in
        d)  dbname="$OPTARG";;
        u)  server_user="$OPTARG";;
        f)  address1="$OPTARG";;
        t)  address2="$OPTARG";;
        \?) echo "Invalid option for $OPTARG" >&2;;
    esac
done

# Check if *any* args supplied
if [ $# -eq 0 ]; then
    printf "Y U NO PROVIDE ANY ARGS\n"
    exit 1 >&2
fi

# Check if *all* args supplied
for argname in $dbname $server_user $address1 $address2; do
    if [ -z $argname ]; then
        printf "You must supply all of -d, -u, -f, and -t args\n"
        exit 1 >&2
    fi
done

# I don't know if these can be assigned in-place above, so this is here for posterity
address1="$server_user"@"$address1"
address2="$server_user"@"$address2"

bindings="-L 3306:localhost:3306"
# I'm open to changing this
folder="/tmp"

# Check if .my.cnf file exists in -u home directories
for addr in $address1 $address2; do
    if ssh $addr "[ ! -e ~${server_user}/.my.cnf ]"; then
        printf "No remote MySQL config file found on $addr"
        exit 1 >&2
    fi
done

# Dump database
printf "Running mysqldump on DB %s, as %s\n" "$dbname" "$address1"
ssh $address1 $bindings "mysqldump $dbname > $folder/dump.sql"

# Transfer dumpfile
printf "Transferring mysqldump to %s\n" "$address2"
scp $address1:$folder/dump.sql "$folder/dump.sql"
scp "$folder/dump.sql" $address2:$folder/dump.sql

# Load dump to new DB server
printf "Loading DB %s into mysql, as %s\n" "$dbname" "$address2"
ssh $address2 $bindings "mysql $dbname < $folder/dump.sql"

# Clean up
printf "Cleaning up transfer mess locally, and on %s and %s\n" "$address1" "$address2"
rm "$folder/dump.sql"
ssh $address1 "rm $folder/dump.sql"
ssh $address2 "rm $folder/dump.sql"

printf "Done.\n"
exit 0
