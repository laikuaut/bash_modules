### bash用の便利モジュールファイル

# コマンド実行関数
# [概要]
#   実行コマンドのログを残すための関数
#   exec_cmdを介して実行したコマンドは、標準出力、標準エラー出力のログファイルを生成する。
#   また、実行コマンド文字列＋戻り値をexec_cmd.logに保存する。
# [生成ファイル]
#   サブシェル実行ではない場合
#     コマンド標準出力ログ       : {ログディレクトリ}/{exec_cmd実行回数}.{コマンド名}.stdout.{実行時刻}.{呼び出し元PID}.log
#     コマンド標準エラー出力ログ : {ログディレクトリ}/{exec_cmd実行回数}.{コマンド名}.stderr.{実行時刻}.{呼び出し元PID}.log
#   サブシェル実行の場合
#     コマンド標準出力ログ       : {ログディレクトリ}/{exec_cmd実行回数}.{コマンド名}.stdout.{実行時刻}.{呼び出し元PID}.{サブシェルPID}.log
#     コマンド標準エラー出力ログ : {ログディレクトリ}/{exec_cmd実行回数}.{コマンド名}.stderr.{実行時刻}.{呼び出し元PID}.{サブシェルPID}.log
#   コマンド履歴               : {ログディレクトリ}/exec_cmd.log
# [パラメータ]
#   $@ : コマンドリスト
# [戻り値]
#   実行コマンドの戻り値
# [使い方]
#   通常実行
#     exec_cmd cat sample.txt
#     exec_cmd 'cat sample.txt'
#   パイプを含めた実行1(logファイルはcatにまとめられる)
#     exec_cmd cat sample.txt \| grep "A"
#     exec_cmd 'cat sample.txt | grep "A"'
#   パイプを含めた実行2(exec_cmdの数だけlogファイルが作成される)
#     exec_cmd cat sample.txt | exec_cmd grep "A"
function exec_cmd() {

  # ログ出力ディレクトリ取得
  if [ ! -v cmd_log_dir ];then
    cmd_log_dir=./log
  fi

  # ログディレクトリを作成
  if [ ! -e ${cmd_log_dir} ];then
    mkdir ${cmd_log_dir} -p
  fi

  # exec_cmd関数の実行回数を初期化
  if [ ! -v exec_cmd_count ];then
    exec_cmd_count=0
    echo "${exec_cmd_count}" > ${cmd_log_dir}/exec_cmd_count.log
  fi
  exec_cmd_count=`cat ${cmd_log_dir}/exec_cmd_count.log | tail -n 1`

  # 実行コマンドをprint
  echo "##### 実行コマンド${exec_cmd_count}:${@}" | tee -a ${cmd_log_dir}/exec_cmd.log >&2

  # 文字列で渡された場合の対処(ログ名に使用するコマンド名だけを取得)
  cmd=`echo ${1} | awk '{print $1}'`
  if [[ ${$} = ${BASHPID} ]];then
    # サブシェル実行ではない場合
    { { eval ${@} | tee ${cmd_log_dir}/${exec_cmd_count}.${cmd}.stdout.`date "+%Y%m%d-%H%M%S"`.${$}.log >&3;  } 2>&1 \
                  | tee ${cmd_log_dir}/${exec_cmd_count}.${cmd}.stderr.`date "+%Y%m%d-%H%M%S"`.${$}.log ;     } 3>&1
  else
    # サブシェル実行の場合
    { { eval ${@} | tee ${cmd_log_dir}/${exec_cmd_count}.${cmd}.stdout.`date "+%Y%m%d-%H%M%S"`.${$}.${BASHPID}.log >&3;  } 2>&1 \
                  | tee ${cmd_log_dir}/${exec_cmd_count}.${cmd}.stderr.`date "+%Y%m%d-%H%M%S"`.${$}.${BASHPID}.log ;     } 3>&1
  fi
  ret=$?
  echo "### コマンド戻り値:$ret" | tee -a ${cmd_log_dir}/exec_cmd.log >&2;

  # exec_cmd関数の実行回数を更新
  exec_cmd_count=$((exec_cmd_count + 1))
  echo "${exec_cmd_count}" >> ${cmd_log_dir}/exec_cmd_count.log

  # コマンド結果を返却
  return $ret
}

function get_abspath() {
  for dir in $@
  do
    echo $(cd $(dirname ${dir}) && pwd | sed -E 's#^/$##')/$(basename ${dir})
  done
  return 0
}
