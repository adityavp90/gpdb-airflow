# Extended Dan Baskette's repo - https://github.com/dbbaskette/gpdb-docker
FROM centos:6.7

COPY * /tmp/

ARG GPDB_INSTALLER
ARG DATA_SCIENCE_PYTHON_INSTALLER
ARG MADLIB_INSTALLER
ARG POSTGIS_INSTALLER

ARG SCRIPTS_DIR="/tmp/"

RUN ${SCRIPTS_DIR}/os.sh
RUN ${SCRIPTS_DIR}/greenplum.sh
RUN ${SCRIPTS_DIR}/addons.sh
RUN ${SCRIPTS_DIR}/cleanup.sh


EXPOSE 5432 5432

VOLUME /gpdata
# Set the default command to run when starting the container
#ENTRYPOINT /bin/bash

CMD echo "127.0.0.1 $(cat ~/orig_hostname)" >> /etc/hosts \
        && service sshd start \
        && su gpadmin -l -c "/usr/local/bin/run.sh" \
        && /bin/bash