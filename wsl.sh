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
    echo_msg error "加载函数失败"
    exit 1
fi
echo_msg info "parsing ${CONFILE}."
create_variables ${CONFILE} conf_
echo_msg info "conf_ssh_keys: ${#conf_ssh_keys[@]}"
echo_msg info "conf_pkgs: ${#conf_pkgs[@]}"
echo_msg info "conf_galaxy: ${#conf_galaxy[@]}"
echo_msg info "conf_services: ${#conf_services[@]}"

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
    apt install -y ${pkgs} > /dev/null 2>&1
}

# ansible roles ${conf_galaxy[@]}
function install_ansible_roles() {
    if [ ${#conf_galaxy[@]} -eq 0 ];then
        echo_msg info "[install_ansible_roles] pass."
        return
    fi
    roles=${conf_galaxy[@]}
    for role in ${roles}; do
        ansible-galaxy collection install ${role} > /dev/null 2>&1
        if [ "$?" -ne 0 ];then
            echo_msg warn "[${role}] collection install failed!!!"
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
        echo_msg info  "[${service}] starting..."
        sleep 0.1
        /etc/init.d/${service} start
        if [ "$?" -ne 0 ];then
            echo_msg warn "[${service}] start failed!!!"
        fi
    done
}

add_ssh_keys
install_pkgs
install_ansible_roles
start_services
echo_msg info "Done."
