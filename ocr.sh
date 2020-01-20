#!/bin/bash

CREDENTIALS=${1}
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

gdrives="$(pwd)/gdrive --service-account ${CREDENTIALS}"

while [ 1 ]; do
    echo "starting..."
    mkdir -p ./workspace/

    cd workspace

    last_changed=$($gdrives list --query "name contains 'last_changed.info'" | grep last_changed.info)
    last_changed_id=$(echo ${last_changed} | awk '{print $1}')
    last_changed_name=$(readlink -f $(echo ${last_changed} | awk '{print $2}'))

    $gdrives download --force ${last_changed_id}

    last_changed_date=$(cat ${last_changed_name})

    date -u +%Y-%m-%dT%H:%M:%S > ${last_changed_name}
    echo "changing last changed date to $(cat ${last_changed_name})"
    $gdrives update ${last_changed_id} ${last_changed_name}

    echo "getting files"
    inbox_id=$($gdrives list --query "name contains '_inbox'" | grep inbox | awk '{print $1}')
    files=$($gdrives list --query "'${inbox_id}' in parents and createdTime > '${last_changed_date}' and name contains 'pdf'" | tail -n+2)

    if [ "$files" != "" ]; then
        while IFS= read -r line; do
            file="${line}"
            file_id=$(echo ${file} | awk '{print $1}')
            
            $gdrives download ${file_id}
            file_name="$(readlink -f $(echo ${file} | awk '{print $2}'))"
            echo $file_name

            echo "ocr file ${file_name}"
            echo "ocrmypdf --rotate-pages -l deu \"${file_name}\" \"${file_name}\""

            $gdrives update ${file_id} ${file_name}

        done <<< "$files"
    else
        echo "no new files found"
    fi
    cd ..
    rm -rf workspace
    echo "sleeping 5m..."
    sleep 300
done

