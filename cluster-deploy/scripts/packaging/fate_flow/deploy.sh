#!/bin/bash
set -e
module_name="fate_flow"
cwd=$(cd `dirname $0`; pwd)
cd ${cwd}
source ./configurations.sh

usage() {
	echo "usage: $0 {binary/build} {packaging|config|install|init} {configurations path}."
}

deploy_mode=$1
config_path=$3
if [[ ${config_path} == "" ]] || [[ ! -f ${config_path} ]]
then
	usage
	exit
fi
source ${config_path}

# deploy functions

packaging() {
    source ../../default_configurations.sh
    package_init ${output_packages_dir} ${module_name}
	cp -r ${source_code_dir}/${module_name} ${output_packages_dir}/source
	return 0
}

config() {
    party_label=$4
	cd ${output_packages_dir}/config/${party_label}
	cp ${source_code_dir}/${module_name}/service.sh ./${module_name}/conf
	cp ${source_code_dir}/${module_name}/settings.py ./${module_name}/conf
	cd ./${module_name}/conf

	sed -i "s#PYTHONPATH=.*#PYTHONPATH=${python_path}#g" ./service.sh
	sed -i "s#venv=.*#venv=${venv_dir}#g" ./service.sh
	sed -i "s/WORK_MODE =.*/WORK_MODE = 1/g" ./settings.py
	sed -i "s/'user':.*/'user': '${db_user}',/g" ./settings.py
	sed -i "s/'passwd':.*/'passwd': '${db_password}',/g" ./settings.py
	sed -i "s/'host':.*/'host': '${db_ip}',/g" ./settings.py
	sed -i "s/'name':.*/'name': '${db_name}',/g" ./settings.py
	sed -i "s/'password':.*/'password': '${redis_password}',/g" ./settings.py
	sed "/'host':.*/{x;s/^/./;/^\.\{2\}$/{x;s/.*/    'host': '${redis_ip}',/;x};x;}" ./settings.py
	return 0
}

install () {
    mkdir -p ${deploy_dir}/${module_name}
    cp -r ${deploy_packages_dir}/source/${module_name} ${deploy_dir}
    cp -r ${deploy_packages_dir}/config/${module_name}/conf/* ${deploy_dir}/${module_name}
}

init (){
	return 0
}

case "$2" in
    packaging)
        packaging $*
        ;;
    config)
        config $*
        ;;
    install)
        install $*
        ;;
    init)
        init $*
        ;;
	*)
	    usage
        exit -1
esac
