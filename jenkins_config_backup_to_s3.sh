#!/bin/bash 

TIMESTAMPED_TAG=`date +%Y-%m-%d-%H%M%S`
BACKUP_CABINATE="<location of backup dump directory>"
BACKUP_DIR="${BACKUP_CABINATE}/backup-${TIMESTAMPED_TAG}/jenkins"
BACKUP_ARCHIVE="${BACKUP_CABINATE}/jenkins-backup-${TIMESTAMPED_TAG}.tar.gz"

rm config_files_paths.txt

echo -e "Create a directory for the job definitions"
mkdir -p $BACKUP_DIR/jobs
echo "------------------------------"

echo -e "Copy global configuration files"
cp $JENKINS_HOME/*.xml $BACKUP_DIR/
echo "------------------------------"

echo -e "Copy keys and secrets"
cp $JENKINS_HOME/identity.key.enc $BACKUP_DIR/
cp $JENKINS_HOME/secret.key $BACKUP_DIR/
cp $JENKINS_HOME/secret.key.not-so-secret $BACKUP_DIR/
cp -r $JENKINS_HOME/secrets $BACKUP_DIR/
echo "------------------------------"

echo -e "Copy plugins configuration files"
cp -r $JENKINS_HOME/plugins $BACKUP_DIR/
echo "------------------------------"

echo -e "Copy user configuration files"
cp -r $JENKINS_HOME/nodes $BACKUP_DIR/
echo "------------------------------"

echo -e "Copy fingerprints files"
cp -r $JENKINS_HOME/fingerprints $BACKUP_DIR/
echo "------------------------------"

echo -e "Copy user configuratio"
cp -r $JENKINS_HOME/users $BACKUP_DIR/
echo "------------------------------"

echo -e "Copy custom Pipeline workflow libraries"
cp -r $JENKINS_HOME/workflow-libs $BACKUP_DIR/
echo "------------------------------"

echo -e "Copy config-history files"
rsync -a --exclude 'queue' $JENKINS_HOME/config-history $BACKUP_DIR/config-history
echo "------------------------------"

echo -e "Gather list of all job config files"
cd /var/lib/jenkins
find ./jobs/ -name "config.xml" >> ${WORKSPACE}/config_files_paths.txt
echo "------------------------------"

echo -e "Copy job definitions"
cd ${WORKSPACE}
rsync -av --files-from=${WORKSPACE}/config_files_paths.txt ${JENKINS_HOME}/ ${BACKUP_DIR}/
echo "------------------------------"

echo -e "Create an archive from all copied files"
tar czf ${BACKUP_ARCHIVE} -C ${BACKUP_CABINATE}/backup-${TIMESTAMPED_TAG} .
echo "------------------------------"

#Copy backup to s3, change bucket name
aws s3 cp ${BACKUP_ARCHIVE} s3://<s3_bucket_name>/
