# just keep wsl run in background
# tmux new -s backgroundsession
ROOT_DIR=$(dirname ${BASH_SOURCE})
CONFILE=${ROOT_DIR}/config.yml

function echo_msg(){
    fname=${FUNCNAME[@]:0-2:1}
    case $1 in
        error) shift; echo -e "[${fname/echo_msg/main}]::[$(date +%F" "%H:%M:%S)] -- [ERROR]: $@" ;;
        warn) shift; echo -e "[${fname/echo_msg/main}]::[$(date +%F" "%H:%M:%S)] -- [WARNING]: $@" ;;
        info) shift; echo -e "[${fname/echo_msg/main}]::[$(date +%F" "%H:%M:%S)] -- [INFO]: $@" ;;
        *) : ;;
    esac
}

if [ -f "${ROOT_DIR}/utils.sh" ]; then
    source "${ROOT_DIR}/utils.sh"
    echo_msg info "load [utils.sh]..."
else
    echo_msg error "load [utils.sh] failed!!!"
    exit 1
fi
echo_msg info "parsing ${CONFILE}."
create_variables ${CONFILE} conf_
echo_msg info "conf_ssh_keys: ${#conf_ssh_keys[@]}"
echo_msg info "conf_pkgs: ${#conf_pkgs[@]}"
echo_msg info "conf_galaxy: ${#conf_galaxy[@]}"
echo_msg info "conf_services: ${#conf_services[@]}"

# cn settings
function cn_init() {
    if [ "${#conf_is_cn[@]}" -ne "true" ];then
        echo_msg info "[cn_init] pass."
        return
    fi
    if [ ! -f "/etc/pip.conf" ];then

    cat > /etc/pip.conf << EOF
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host=mirrors.aliyun.com
EOF
    echo_msg info "[cn_init] add aliyun pypi success."
    fi
    sed -i 's+archive.ubuntu.com+mirrors.aliyun.com+g' /etc/apt/sources.list &&
    apt update -y &&
    echo_msg info "[cn_init] change apt sources to aliyun success."
}

# Add ssh keys
function add_ssh_keys() {
    if [ "${#conf_ssh_keys[@]}" -eq 0 ];then
        echo_msg info "[add_ssh_keys] pass."
        return
    fi
    ssh_keys=${conf_ssh_keys[@]}
    for ssh_key in "${ssh_keys}"; do
        mkdir -p ~/.ssh/
        echo ${ssh_key} > ~/.ssh/authorized_keys &&
        chmod 600 ~/.ssh/authorized_keys &&
        echo_msg info "[add_ssh_keys] success."
        if [ "$?" -ne 0 ];then
            echo_msg warn "[add_ssh_keys] failed!!!"
        fi
    done
}

# Install pkgs ${conf_pkgs[@]}
function install_pkgs() {
    if [ "${#conf_pkgs[@]}" -eq 0 ];then
        echo_msg info "[install_pkgs] pass."
        return
    fi
    pkgs=${conf_pkgs[@]}
    echo_msg info "[install_pkgs]: ${pkgs}"
    apt update -y
    for pkg in ${pkgs}; do
        apt install -y ${pkg}
    done
}

# ansible roles ${conf_galaxy[@]}
function install_ansible_roles() {
    if [ ${#conf_galaxy[@]} -eq 0 ];then
        echo_msg info "[install_ansible_roles] pass."
        return
    fi
    roles=${conf_galaxy[@]}
    echo_msg info "[install_ansible_roles]: ${roles}"
    for role in ${roles}; do
        echo_msg info "[install_ansible_roles:${role}]..."
        ansible-galaxy install ${role}
        cat > /tmp/${role}.yml << EOF
---
- hosts: localhost
  remote_user: root
  roles:
    - "${role}"
EOF
        ansible-playbook /tmp/${role}.yml
        if [ "$?" -ne 0 ];then
            echo_msg warn "[${role}] install failed!!!"
        fi
    done
}

# start services ${#conf_services[@]}
function start_services() {
    if [ "${#conf_services[@]}" -eq 0 ];then
        echo_msg info "[start_services] pass."
        return
    fi
    for service in ${conf_services[@]}; do
        if [ "$service" -eq "ssh" ];then
            yes | ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -q -N ""
            yes | ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N ""
        fi
        echo_msg info  "[${service}] starting..."
        sleep 0.1
        /etc/init.d/${service} start
        if [ "$?" -ne 0 ];then
            echo_msg warn "[${service}] start failed!!!"
        fi
    done
}

cn_init
add_ssh_keys
install_pkgs
install_ansible_roles
start_services
echo_msg info "Done."
