#################################################
# Description: A quick script to upgrade RMQ
#
#   Author:    Haydon Murdoch
#   Date:      2014.12.12
#
#################################################

function delay {
    sleep 1
}

function newline {
    echo ""
}

function distro_check {
    distro=$(lsb_release -si)

    if [ $distro == "CentOS" ]; then
        check_rmq_version
        upgrade_rmq_version
    else
        echo "Unsupported distro"
        exit 1
    fi
}

function check_rmq_version {
    rmq_version=$(sudo rabbitmqctl status | grep "rabbit," | cut -d',' -f3 | cut -d'}' -f1)
    newline && echo "    Version = $rmq_version" && newline
}

function upgrade_rmq_version {
    echo "Changing directory to /tmp..."
    cd /tmp
    delay && newline

    echo "wgetting RabbitMQ .rpm file from official website..."
    url="http://www.rabbitmq.com/releases/rabbitmq-server/v3.4.2/rabbitmq-server-3.4.2-1.noarch.rpm"
    wget $url
    delay && newline

    echo "Validating signature..."
    url="http://www.rabbitmq.com/rabbitmq-signing-key-public.asc"
    sudo rpm --import $url
    delay && newline

    echo "Upgrading RabbitMQ version..."
    file="rabbitmq-server-3.4.2-1.noarch.rpm"
    sudo yum install $file
    delay && newline

    start_rmq
    check_rmq_version
}

function start_rmq {
    sudo service rabbitmq-server start
}

function main {
    distro_check
}

main
