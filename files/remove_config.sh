#!/bin/bash

rm -rf /opt/pentaho-solutions/system/publisher_config.xml /opt/enterprise-console/resource/config/console.xml /opt/pentaho-solutions/system/quartz/quartz.properties /opt/administration-console/resource/config/console.xml /srv/tomcat/pentaho_biserver/webapps/pentaho/META-INF/context.xml /srv/tomcat/pentaho_biserver/conf/Catalina/localhost/pentaho.xml /srv/tomcat/pentaho_biserver/webapps/pentaho/WEB-INF/web.xml /opt/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties /opt/pentaho-solutions/system/hibernate/mysql5.hibernate.cfg.xml /opt/pentaho-solutions/system/hibernate/hibernate-settings.xml /srv/tomcat/pentaho_biserver/webapps/pentaho/WEB-INF/classes/log4j.xml
mkdir -p /srv/tomcat/pentaho_biserver/conf/Catalina/localhost/
touch /opt/.pentahoinit
