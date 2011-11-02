class pentaho::mysql {

include mysql::server

mysql::database{"hibernate":
  ensure   => present
}


mysql::rights{"hibernate rights":
  ensure   => present,
  database => "hibernate",
  user     => "hibuser",
  password => "password",
  require => Mysql::Database["hibernate"],
}

file { "/tmp/create_repository_mysql.sql":
    mode => 440,
    owner => root,
    group => root,
    source => "puppet:///modules/pentaho/create_repository_mysql.sql",
    require => Mysql::Rights["hibernate rights"],
    notify => Exec["importhibernate"],
}

exec { "importhibernate":
        cwd => "/tmp",
        command => "mysql -uroot hibernate < /tmp/create_repository_mysql.sql",
        refreshonly => true,
        require => File["/tmp/create_repository_mysql.sql"],
}


file { "/tmp/create_sample_datasource_mysql.sql":
    mode => 440,
    owner => root,
    group => root,
    source => "puppet:///modules/pentaho/create_sample_datasource_mysql.sql",
    require => Mysql::Rights["hibernate rights"],
    notify => Exec["importhibernate2"],
}

exec { "importhibernate2":
        cwd => "/tmp",
        command => "mysql -uroot hibernate < /tmp/create_sample_datasource_mysql.sql",
        refreshonly => true,
        require => File["/tmp/create_sample_datasource_mysql.sql"],
}


mysql::database{"sampledata":
  ensure   => present
}


mysql::rights{"sampledata rights":
  ensure   => present,
  database => "sampledata",
  user     => "pentaho_user",
  password => "password",
  require => Mysql::Database["sampledata"],
}

file { "/tmp/sampledata.sql":
    mode => 440,
    owner => root,
    group => root,
    source => "puppet:///modules/pentaho/sampledata.sql",
    require => Mysql::Rights["sampledata rights"],
    notify => Exec["importsampledata"],
}

exec { "importsampledata":
        cwd => "/tmp",
        command => "mysql -uroot sampledata < /tmp/sampledata.sql",
        refreshonly => true,
        require => File["/tmp/sampledata.sql"],
}


mysql::database{"quartz":
  ensure   => present
}


mysql::rights{"quartz rights":
  ensure   => present,
  database => "quartz",
  user     => "pentaho_user",
  password => "password",
  require => Mysql::Database["quartz"],
}

file { "/tmp/create_quartz_mysql.sql":
    mode => 440,
    owner => root,
    group => root,
    source => "puppet:///modules/pentaho/create_quartz_mysql.sql",
    require => Mysql::Rights["quartz rights"],
    notify => Exec["importquartz"],
}

exec { "importquartz":
        cwd => "/tmp",
        command => "mysql -uroot quartz < /tmp/create_quartz_mysql.sql",
        refreshonly => true,
        require => File["/tmp/create_quartz_mysql.sql"],
}



    #pentaho/META-INF/context.xml
	file { '/opt/apache-tomcat/pentaho/META-INF/context.xml':
        ensure  => present,
        content => template('pentaho/pentaho_context.xml.erb'),
        mode    => 755,
        require => Package['tomcat7-alabs'],
        notify  => Service['tomcat7'],
   }

    #pentaho/WEB-INF/web.xml
        file { '/opt/apache-tomcat/pentaho/WEB-INF/web.xml':
        ensure  => present,
        content => template('pentaho/pentaho_web.xml.erb'),
        mode    => 755,
        require => Package['tomcat7-alabs'],
        notify  => Service['tomcat7']
    }

    #pentaho-solutions/system/applicationContext-spring-security-hibernate.properties
        file { '/opt/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties':
        ensure  => present,
        content => template('pentaho/solution_applicationContext-spring-security-hibernate.properties.erb'),
        mode    => 755,
        require => Package['tomcat7-alabs'],
        notify  => Service['tomcat7']
    }

    #pentaho-solutions/system/hibernate/mysql5.hibernate.cfg.xml
        file { '/opt/pentaho-solutions/system/hibernate/mysql5.hibernate.cfg.xml':
        ensure  => present,
        content => template('pentaho/solution_mysql5.hibernate.cfg.xml.erb'),
        mode    => 755,
        require => Package['tomcat7-alabs'],
        notify  => Service['tomcat7']
    }

}
