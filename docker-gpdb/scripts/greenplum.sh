#!/usr/bin/env bash

# Install and Initialize Greenplum

unzip /tmp/${GPDB_INSTALLER}.zip -d /tmp/
rm /tmp/${GPDB_INSTALLER}.zip
sed -i s/"more << EOF"/"cat << EOF"/g /tmp/${GPDB_INSTALLER}.bin
echo -e "yes\n\nyes\nyes\n" | /tmp/${GPDB_INSTALLER}.bin
rm /tmp/${GPDB_INSTALLER}.bin
cat /tmp/sysctl.conf.add >> /etc/sysctl.conf
cat /tmp/limits.conf.add >> /etc/security/limits.conf
rm -f /tmp/*.add
echo "localhost" > /tmp/gpdb-hosts
chmod 777 /tmp/gpinitsystem_singlenode
hostname > ~/orig_hostname
mv /tmp/run.sh /usr/local/bin/run.sh
mv /tmp/start_gp.sh /usr/local/bin/start_gp.sh
chmod +x /usr/local/bin/run.sh
chmod +x /usr/local/bin/start_gp.sh
/usr/sbin/groupadd gpadmin
/usr/sbin/useradd gpadmin -g gpadmin -G wheel
echo "pivotal"|passwd --stdin gpadmin
echo "gpadmin        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
mv /tmp/bash_profile /home/gpadmin/.bash_profile
chown -R gpadmin: /home/gpadmin
mkdir -p /gpdata/master /gpdata/segments
chown -R gpadmin: /gpdata
chown -R gpadmin: /usr/local/green*
service sshd start
su gpadmin -l -c "source /usr/local/greenplum-db/greenplum_path.sh;gpssh-exkeys -f /tmp/gpdb-hosts"
su gpadmin -l -c "source /usr/local/greenplum-db/greenplum_path.sh;gpinitsystem -a -c  /tmp/gpinitsystem_singlenode -h /tmp/gpdb-hosts; exit 0 "
su gpadmin -l -c "export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1;source /usr/local/greenplum-db/greenplum_path.sh;psql -d template1 -c \"alter user gpadmin password 'pivotal'\"; createdb gpadmin;  exit 0"

su gpadmin -l -c "echo 'export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1' >> ~/.bashrc"
su gpadmin -l -c "echo 'source /usr/local/greenplum-db/greenplum_path.sh' >> ~/.bashrc"
