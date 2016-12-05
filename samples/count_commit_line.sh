#!/bin/bash -ue

##
# gitにコミットされている行数を数える
# 参考 : http://qiita.com/Night___/items/359ff81f358968567a45

if [[ $# == 1 ]];then
    since=$(date -d "${1} 1 days ago" +"%Y-%m-%d")
    until=$(date -d ${1} +"%Y-%m-%d")
else
    today=$(date +"%Y%m%d")
    since=$(date -d "${today} 1 days ago" +"%Y-%m-%d")
    until=$(date -d ${today} +"%Y-%m-%d")
fi

log_dir=~/log/${since}_${until}
mkdir -p ${log_dir}

all_count_file=${log_dir}/all_count.log
:> ${all_count_file}
git_log_cmd="git log --numstat --date=short --pretty=\"[%cd] [%h] [%an] %s\" --author='laikuaut' --since=${since} --until=${until} --no-merges"
find -mindepth 1 -maxdepth 1 -type d | while read line
do
    pushd ${line} >& /dev/null
    log_file=${log_dir}/${line#./}.log
    :> ${log_file}
    echo -n "# ${line#./}" | tee -a ${log_file} | tee -a ${all_count_file}
    echo -n " : " | tee -a ${all_count_file}
    echo >> ${log_file}
    git log --numstat \
            --date=short \
            --pretty="[%cd] [%h] [%an] %s" \
            --author='laikuaut' \
            --since=${since} \
            --until=${until} \
            --no-merges >> ${log_file}

    git log --numstat \
            --date=short \
            --pretty="[%cd] [%h] [%an] %s" \
            --author='laikuaut' \
            --since=${since} \
            --until=${until} \
            --no-merges \
                | awk 'NF==3 {plus+=$1; minus+=$2} END {printf("%d (+%d, -%d)\n", plus+minus, plus, minus)}' \
                | tee -a ${all_count_file}
    popd >& /dev/null
done

echo -n '合計 : ' | tee -a ${all_count_file}
cat ${all_count_file} \
    | sed -E 's#^\#.+\(\+([0-9]+), \-([0-9]+)\)#\1\t\2#' \
    | awk '{plus+=$1; minus+=$2} END {printf("%d (+%d, -%d)", plus+minus, plus, minus)}' \
    | tee -a ${all_count_file}
echo | tee -a ${all_count_file}

