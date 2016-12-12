#!/bin/bash -ue

if [[ $# != 1 ]];then
    echo "引数不足"
    echo "リポジトリ名を指定してください。"
    exit 1
fi

repo_name=${1}
user_name=laikuaut

mkdir ${repo_name} -p
cd ${repo_name}
git init
git remote add origin https://gist.github.com/${repo_name}.git
git remote set-url origin git@gist.github.com:${repo_name}.git
git pull origin master
