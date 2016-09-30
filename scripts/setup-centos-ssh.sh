#!/bin/bash
# http://unix.stackexchange.com/questions/59003/why-ssh-copy-id-prompts-for-the-local-user-password-three-times
# http://linuxcommando.blogspot.com/2008/10/how-to-disable-ssh-host-key-checking.html
# http://linuxcommando.blogspot.ca/2013/10/allow-root-ssh-login-with-public-key.html
# http://stackoverflow.com/questions/12118308/command-line-to-execute-ssh-with-password-authentication
# http://www.cyberciti.biz/faq/noninteractive-shell-script-ssh-password-provider/
source "/vagrant/scripts/common.sh"
START=3
TOTAL_NODES=2

while getopts s:t: option
do
	case "${option}"
	in
		s) START=${OPTARG};;
		t) TOTAL_NODES=${OPTARG};;
	esac
done
#echo "total nodes = $TOTAL_NODES"

function installSSHPass {
	yum -y install sshpass
}

function overwriteSSHCopyId {
	cp -f $RES_SSH_COPYID_MODIFIED /usr/bin/ssh-copy-id
}

function createSSHKey () {
	USER=$1
	echo "generating ssh key for $USER"
	su -s /bin/bash $USER -c "ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa"
	su -s /bin/bash $USER -c "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
	su -s /bin/bash $USER -c "cp -f $RES_SSH_CONFIG ~/.ssh"
}

function sshCopyId () {
	USER=$1
	echo "executing ssh-copy-id for $USER"
	for i in $(seq $START $TOTAL_NODES)
	do
		node="spark-notebook${i}.example.com"
		echo "copy ssh key to $USER@${node}"
		sudo sshpass -p "$USER" sudo ssh-copy-id -i /home/$USER/.ssh/id_rsa.pub $USER@${node}
	done
}

function knownHosts () {
	USER=$1
	SSH_DIR="/home/$USER/.ssh"
	if [ "$USER" == "root" ];
	then
		SSH_DIR="/root/.ssh"
	fi
	echo "adding to known hosts"
	for i in $(seq $START $TOTAL_NODES)
	do
		node="spark-notebook${i}.example.com"
		sudo mkdir -p $SSH_DIR
		sudo /bin/bash -c "ssh-keyscan ${node} >> ${SSH_DIR}/known_hosts"
		sudo chown -R $USER:$USER $SSH_DIR
		#echo $(ssh-keyscan ${node}) >> ~/.ssh/known_hosts
	done
}

echo "setup ssh"
installSSHPass
#overwriteSSHCopyId
createSSHKey $HDFS_USER
createSSHKey $SPARK_USER
knownHosts "root"
knownHosts "vagrant"
knownHosts $HDFS_USER
knownHosts $SPARK_USER
sshCopyId $HDFS_USER
sshCopyId $SPARK_USER
