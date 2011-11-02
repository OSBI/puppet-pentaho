import "classes/*.pp"

class pentaho {

include tomcat

    package { 'pentaho':
        ensure => latest,
        notify  => Service['tomcat7'],
	require => Package['tomcat7-alabs'],
    }


}
