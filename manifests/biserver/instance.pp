#
# pentahoinstance.pp
# 
# Copyright (c) 2011, OSBI Ltd. All rights reserved.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301  USA
#
define pentaho::biserver::instance ($ensure,
	$tomcat_http,
	$tomcat_ajp,
	$tomcat_server,
	$database, 
	$pentaho_enterprise = false) {
	$tomcat_version = "6.0.29"
	include tomcat::source 
	#NEED VECTORWISE
	if ($database == "mysql") {
		include pentaho::mysql 
		include pentaho::apt
		tomcat::instance {
			"pentaho_biserver" :
				ensure => present,
				ajp_port => "${tomcat_ajp}",
				server_port => "${tomcat_server}",
				http_port => "${tomcat_http}",
				group => "pentaho",
				require => Group["pentaho"],
		} 
		class {
			"pentaho::server" :
				database => $database,
				pentaho_enterprise => $pentaho_enterprise,
				
		}
		
	}
	if ($database == "postgresql") {
		include	pentaho::postgresql
		
		tomcat::instance {
			"pentaho_biserver" :
				ensure => present,
				ajp_port => "${tomcat_ajp}",
				server_port => "${tomcat_server}",
				http_port => "${tomcat_http}",
				group => "pentaho",
				require => Group["pentaho"],
		} 
		class {
			"pentaho::server" :
				database => $database,
        pentaho_enterprise => $pentaho_enterprise,
				require => [Postgresql::Database["hibernate"], Postgresql::Database["quartz"], Postgresql::Database["sampledata"]]
		}
		
	}
	if ($database == "vectorwise") {
		include pentaho::mysql 
		include pentaho::apt
		tomcat::instance {
			"pentaho_biserver" :
				ensure => present,
				ajp_port => "${tomcat_ajp}",
				server_port => "${tomcat_server}",
				http_port => "${tomcat_http}",
				group => "pentaho",
				require => Group["pentaho"],
		} 
		class {
			"pentaho::server" :
				database => $database,
				pentaho_enterprise => $pentaho_enterprise,
				
		}
		##Needs to import Foodmart data source
		
	}
}
