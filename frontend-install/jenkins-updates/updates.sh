#!/bin/bash
# This script rewords basic Jenkins concepts
# to match Quality Assurance domain

if [ "$(whoami)" != "root" ]; then
	echo "Please run this as root user." >&3
	exit 1
fi

source ./constants.sh

output_errors_only


fix_permissions ${JENKINS_INST}
fix_permissions ${JENKINS_CACHE}

# # install UI plugins (CSS & locale)
# cd ../..
# wget -nv ${JEN_URL}/jnlpJars/jenkins-cli.jar -O jenkins-cli.jar 
# ls -1 plugins/*.hpi | xargs -n1 -t java -jar jenkins-cli.jar -s $JEN_URL install-plugin
# rm jenkins-cli.jar

cd $LANG

# main page and other configs
cp *.xml $JENKINS_INST
fix_permissions $JENKINS_INST/*.xml

# localize plugins
for p in plugins/*; do
	cd $p;
	[ -f $JENKINS_INST/$p.jpi ] && jar uf $JENKINS_INST/$p.jpi ./*;
	[ -f $JENKINS_INST/$p.hpi ] && jar uf $JENKINS_INST/$p.hpi ./*;
	cd ../..;
done
fix_permissions $JENKINS_INST/plugins

# add resources
cp -r ./css $JENKINS_CACHE
cp -r ./images $JENKINS_CACHE
fix_permissions $JENKINS_CACHE/css
fix_permissions $JENKINS_CACHE/images

# localize core classes
pwd 
cd ./core
jar xf $JENKINS_WAR_FILE $JENKINS_CORE_NAME
jar uf $JENKINS_CORE_NAME hudson/*
jar uf $JENKINS_CORE_NAME jenkins/*
jar uf $JENKINS_CORE_NAME lib/*
cp $JENKINS_CORE_NAME $JENKINS_CACHE/$JENKINS_CORE_NAME
fix_permissions $JENKINS_CACHE/$JENKINS_CORE_NAME
fix_permissions $JENKINS_CACHE
rm $JENKINS_CORE_NAME

# install UI plugins (CSS & locale)
cd ../..
wget -nv ${JEN_URL}/jnlpJars/jenkins-cli.jar -O jenkins-cli.jar 
ls -1 plugins/*.hpi | xargs -n1 -t java -jar jenkins-cli.jar -s $JEN_URL install-plugin
rm jenkins-cli.jar

default_output

sudo service jenkins restart
