#!/bin/bash
set -ex
show_help () {
cat << USAGE
usage: $0 [ -g ANSIBLE-GROUP ] [ -d CLEAN-OR-NOT ]
    -g : Specify the group for ansible. If not specificed, use "all" by default.
    -d : Define if delete the function of cleaning docker unused resource. 
         "False" by default. 
USAGE
exit 0
}
# Get Opts
while getopts "hg:d" opt; do # 选项后面的冒号表示该选项需要参数
    case "$opt" in
    h)  show_help
        ;;
    g)  GROUP=$OPTARG
        ;;
    d)  DELETE=true 
        ;;
    ?)  # 当有不认识的选项的时候arg为?
        echo "unkonw argument"
        exit 1
        ;;
    esac
done
[[ -z $* ]] && show_help
chk_install () {
if [ ! -x "$(command -v $1)" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no $1 installed !!!"
  sleep 3
  exit 1
fi
}
if ! $DELETE; then
  NEEDS="ansible"
  for NEED in $NEEDS; do
    chk_install $NEED
  done
fi
GROUP=${GROUP:-"all"}
DELETE=${DELETE:-"false"}
FILE=clean-docker-unused-resource.sh
if ! $DELETE; then
  cat > /usr/local/bin/${FILE}<<"EOF"
#!/bin/bash
if [[ -x $(command -v docker) ]]; then
  docker system prune --force
else
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no docker installed !!!"
fi
EOF
  chmod +x /usr/local/bin/${FILE}
else
  rm -f /usr/local/bin/${FILE}
fi
if ! $DELETE; then
  if [[ -z $(cat /etc/crontab | grep ${FILE}) ]]; then
  MIN=$[${RANDOM}%60]
  HOUR=2
  cat >> /etc/crontab <<EOF
$MIN $HOUR * * * root ansible ${GROUP} -m scripts -a "/usr/local/bin/${FILE}"
EOF
  fi
else
  sed -i /"${FILE}"/d /etc/crontab
fi
