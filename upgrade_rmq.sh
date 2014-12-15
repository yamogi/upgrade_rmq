#################################################
# Description: A quick script to upgrade RMQ
#
#   Author:    Haydon Murdoch
#   Date:      2014.12.12
#
#################################################
# To-Do List:
#  - Remove/modify lsb_release function
#    (distro_check) - the machine I ran this on
#    did not have lsb_release installed.
#  - Force stop of RabbitMQ (sudo service...)
#    before running 'yum install' step
#     - This should be a 'safe upgrade', and
#       ensures RabbitMQ is not "stuck in limbo"
#  - Kill stray RMQ processes before attempting
#    to stop it
#     - Especially the "erlang64" one - grep and
#       awk for pid?
#  - Remove delay and newline functions
#     - Replace newlines with a simple "echo"
#################################################

#function distro_check {
#    distro=$(lsb_release -si)
#
#    if [ $distro == "CentOS" ]; then
#        check_rmq_version
#        upgrade_rmq_version
#    else
#        echo "Unsupported distro"
#        exit 1
#    fi
#}

function check_rmq_version {
    rmq_version=$(sudo rabbitmqctl status | grep "rabbit," | cut -d',' -f3 | cut -d'}' -f1 | tr -d '"')
    echo && echo "    Version = $rmq_version" && echo
}

function stop_rmq {
    sudo service rabbitmq-server stop
}

function kill_erlang {
    echo "Killing stray RMQ/erlang processes..."
    pids=$(ps -fe | grep erlang | grep rabbitmq | awk '{ print $2 }')
    echo $pids
}

function upgrade_rmq_version {
    echo "Changing directory to /tmp..."
    cd /tmp
    echo

    echo "wgetting RabbitMQ .rpm file from official website..."
    url="http://www.rabbitmq.com/releases/rabbitmq-server/v3.4.2/rabbitmq-server-3.4.2-1.noarch.rpm"
    wget $url
    echo

    echo "Validating signature..."
    url="http://www.rabbitmq.com/rabbitmq-signing-key-public.asc"
    sudo rpm --import $url
    echo

    echo "Upgrading RabbitMQ version..."
    file="rabbitmq-server-3.4.2-1.noarch.rpm"
    sudo yum install $file
    echo
}

function start_rmq {
    sudo service rabbitmq-server start
}

function main {
    #distro_check        # Checking that the script is running on CentOS
    check_rmq_version   # Checking the current version of RabbitMQ
    stop_rmq            # Stopping the rabbitmq-server service
    kill_erlang         # Killing erlang to ensure RMQ is stopped
    upgrade_rmq_version # Upgrading RabbitMQ
    start_rmq           # Starting the rabbitmq-server service
    check_rmq_version   # Checking the current version of RabbitMQ
}

main
