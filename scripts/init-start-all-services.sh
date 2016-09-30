#!/bin/bash
source "/vagrant/scripts/common.sh"
source "/etc/profile.d/java.sh"

function formatNameNode {
	su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/bin/hdfs namenode -format myhadoop -force -noninteractive"
	echo "formatted namenode"
}

function startHDFS {
	su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/sbin/start-dfs.sh"
	#su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode"
	#su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start datanode"
	#echo "started hdfs"
}

function startYarn() {
	su -s /bin/bash $HDFS_USER -c "$HADOOP_YARN_HOME/sbin/start-yarn.sh"
	#su -s /bin/bash $HDFS_USER -c "$HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start resourcemanager"
	#su -s /bin/bash $HDFS_USER -c "$HADOOP_YARN_HOME/sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR start nodemanager"
	#su -s /bin/bash $HDFS_USER -c "$HADOOP_YARN_HOME/sbin/yarn-daemon.sh start proxyserver --config $HADOOP_CONF_DIR"
	#su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh start historyserver --config $HADOOP_CONF_DIR"
	echo "started yarn"
}

function createHDFSDir {
    su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/bin/hdfs dfs -mkdir /user"
    su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/bin/hdfs dfs -mkdir /user/root"
    su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/bin/hdfs dfs -chown root /user/root"
    su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/bin/hdfs dfs -mkdir /user/spark"
    su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/bin/hdfs dfs -chown spark /user/spark"
  	su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/bin/hdfs dfs -mkdir /apps"

		#su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/bin/hdfs dfs -put /usr/local/spark/jars /user/spark"
		#su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/bin/hdfs dfs -put /usr/local/spark/yarn/* /user/spark/jars"
}

function createEventLogDir {
	su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/bin/hdfs dfs -mkdir /tmp"
	su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/bin/hdfs dfs -mkdir /tmp/spark-events"
	su -s /bin/bash $HDFS_USER -c "$HADOOP_PREFIX/bin/hdfs dfs -chmod -R 1777 /tmp"
	echo "created spark event log dir"
}

function startSpark() {
	su -s /bin/bash $SPARK_USER -c "$SPARK_HOME/sbin/start-all.sh"
  #su -s /bin/bash $SPARK_USER -c "$SPARK_HOME/sbin/start-master.sh"
	#su -s /bin/bash $SPARK_USER -c "$SPARK_HOME/sbin/start-slave.sh spark://spark-notebook1.example.com:7077"
	#su -s /bin/bash $SPARK_USER -c "$SPARK_HOME/sbin/start-history-server.sh"
	echo "started spark"
}

function startSparknotebook {
    $SPARKNOTEBOOK_HOME/start-spark-notebook.sh
    echo "started spark-notebook"
}

function startKafka {
    su -s /bin/bash $KAFKA_USER -c "$KAFKA_HOME/start-kafka.sh"
    echo "started kafka"
}

function setupServices {
    cp -f /vagrant/scripts/start-all-services.sh /etc/init.d/start-all-services
    chmod a+x /etc/init.d/start-all-services
    chkconfig start-all-services on
}

setupServices
formatNameNode
startHDFS
startYarn
createHDFSDir
createEventLogDir
startSpark
startSparknotebook
startKafka
