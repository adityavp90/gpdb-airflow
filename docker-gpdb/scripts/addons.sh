#!/usr/bin/env bash

/usr/local/bin/start_gp.sh
su gpadmin -l -c "gppkg -i /tmp/${DATA_SCIENCE_PYTHON_INSTALLER}.gppkg"
su gpadmin -l -c "echo -ne 'y' | source /usr/local/greenplum-db/greenplum_path.sh"
su gpadmin -l -c "echo -ne 'y' | gpstop -ra"
rm /tmp/${DATA_SCIENCE_PYTHON_INSTALLER}.gppkg

tar -xvf /tmp/${MADLIB_INSTALLER}.tar.gz -C /tmp
rm /tmp/${MADLIB_INSTALLER}.tar.gz
su gpadmin -l -c "gppkg -i /tmp/${MADLIB_INSTALLER}/${MADLIB_INSTALLER}.gppkg"
rm /tmp/${MADLIB_INSTALLER}/${MADLIB_INSTALLER}.gppkg
su gpadmin -l -c "/usr/local/greenplum-db/madlib/bin/madpack -s madlib -p greenplum -c gpadmin@localhost:5432/gpadmin install"

su gpadmin -l -c "gppkg -ai /tmp/${POSTGIS_INSTALLER}.gppkg"

# Install tsfresh
# su gpadmin
su gpadmin -l -c "wget  -P /tmp/ --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-18.4.tar.gz"
su gpadmin -l -c "tar -xf /tmp/setuptools-18.4.tar.gz -C /tmp"
su gpadmin -l -c "python /tmp/setuptools-18.4/setup.py build && python /tmp/setuptools-18.4/setup.py install"
su gpadmin -l -c "/usr/local/greenplum-db/ext/python/bin/easy_install pip"
su gpadmin -l -c "wget -P /tmp/ --no-check-certificate https://files.pythonhosted.org/packages/14/8e/d0b2d72d5c858f763fdec5f7869f9375dbd267a16cff59284f8e1dcde3d0/tsfresh-0.11.0-py2.py3-none-any.whl"
su gpadmin -l -c "LDFLAGS=-L/usr/local/greenplum-db/ext/python/lib/ /usr/local/greenplum-db/ext/python/bin/pip install /tmp/tsfresh-0.11.0-py2.py3-none-any.whl"

