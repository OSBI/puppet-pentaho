class pentaho::server ($database, $pentaho_enterprise) {
	if ($database == "postgresql") {
		$driverClassName = "org.postgresql.Driver"
		$quartzURL = "jdbc:postgresql://localhost:5432/quartz"
		$hibernateURL = "jdbc:postgresql://localhost:5432/hibernate"
		$hibernateUsername = "hibuser"
		$hibernatePassword = "password"
		$hibernateDialect = "org.hibernate.dialect.PostgreSQLDialect"
		$configFile = "system/hibernate/postgresql.hibernate.cfg.xml"
		$quartzDelegate = "org.quartz.impl.jdbcjobstore.PostgreSQLDelegate"
	}
	if ($database == "mysql") {
		$driverClassName = "com.mysql.jdbc.Driver"
		$quartzURL = "jdbc:mysql://localhost/quartz"
		$hibernateURL = "jdbc:mysql://localhost/hibernate"
		$hibernateUsername = "hibuser"
		$hibernatePassword = "password"
		$hibernateDialect = "org.hibernate.dialect.MySQL5InnoDBDialect"
		$configFile = "system/hibernate/mysql5.hibernate.cfg.xml"
		$quartzDelegate = "org.quartz.impl.jdbcjobstore.StdJDBCDelegate"
	}
		if ($database == "vectorwise") {
		$driverClassName = "com.mysql.jdbc.Driver"
		$quartzURL = "jdbc:mysql://localhost/quartz"
		$hibernateURL = "jdbc:mysql://localhost/hibernate"
		$hibernateUsername = "hibuser"
		$hibernatePassword = "password"
		$hibernateDialect = "org.hibernate.dialect.MySQL5InnoDBDialect"
		$configFile = "system/hibernate/mysql5.hibernate.cfg.xml"
		$quartzDelegate = "org.quartz.impl.jdbcjobstore.StdJDBCDelegate"
	}
	$package = $pentaho_enterprise ? {
    true      => "pentaho-biserver-ee",
    default => "pentaho-biserver",
  }

		package {
			"$package":
			ensure => present,
			require => [Class["pentaho::apt"],Exec['apt-get_update']],
			alias  => "pentaho-biserver",
		}
	
	group { "pentaho":
		ensure => present,
	}
	exec {
		"chown /opt/pentaho-solutions" :
			command => "chown -R tomcat:pentaho /opt/pentaho-solutions/",
			require => [Package["pentaho-biserver"], Group["pentaho"]],
	}
	file {
		"/usr/bin/remove_config.sh" :
			source => "puppet:///modules/pentaho/remove_config.sh",
			mode => 700,
			ensure => present,
			owner => "tomcat",
			group => "pentaho",
			require => Group["pentaho"],
			
	}
	exec {
		"remove dud configs" :
			command => "/usr/bin/remove_config.sh",
			creates => "/opt/.pentahoinit",
			require => [File["/usr/bin/remove_config.sh"], Package["pentaho-biserver"]]
	}
	file {
		'/opt/pentaho-solutions/system/quartz/quartz.properties' :
			ensure => present,
			content => template('pentaho/quartz.properties.erb'),
			mode => 755,
			require => [Package["pentaho-biserver"], Exec["remove dud configs"], Group["pentaho"]],
			replace => false,
			owner => "tomcat",
			group => "pentaho",
			notify => Service["tomcat-pentaho_biserver"],
	}

    $jettyservice = $pentaho_enterprise ? {
      true      => "jetty-pentahoenterprise",
      default => "jetty-pentaho_adminserver",
    }
    
    file{"/etc/init.d/jetty-pentaho_adminserver":
      ensure => present,
      source => "puppet:///modules/pentaho/jettyinit_ce",
      mode => 0755,
    }

    service{ "$jettyservice":
      enable => true,
      ensure => "running",
      require => [Package["pentaho-biserver"],File["/etc/init.d/jetty-pentaho_adminserver"],Service["tomcat-pentaho_biserver"]],
    }
       $consolepath = $pentaho_enterprise ? {
	    true      => "/opt/enterprise-console/resource/config/console.xml",
	    default => "/opt/administration-console/resource/config/console.xml",
  	}



	$consoletemplate = $pentaho_enterprise ? {
		true => "pentaho/admin_console-ee.xml.erb",
		default => "pentaho/admin_console.xml.erb",
	}
	file {
		"$consolepath" :
			ensure => present,
			content => template("$consoletemplate"),
			mode => 755,
			require => [Package["pentaho-biserver"], Exec["remove dud configs"], Group["pentaho"]],
			replace => false,
			owner => "tomcat",
			group => "pentaho",
			notify => Service["tomcat-pentaho_biserver"],
	}

	#pentaho/META-INF/context.xml
	file {
		'/srv/tomcat/pentaho_biserver/webapps/pentaho/META-INF/context.xml' :
			ensure => present,
			content => template('pentaho/pentaho_context.xml.erb'),
			mode => 755,
			require => [Package["pentaho-biserver"], Exec["remove dud configs"], Group["pentaho"]],
			notify => Service["tomcat-pentaho_biserver"],
			owner => "tomcat",
			group => "pentaho",
			replace => false,
	}

	#pentaho/META-INF/context.xml
	file {
		'/srv/tomcat/pentaho_biserver/conf/Catalina/localhost/pentaho.xml' :
			ensure => present,
			content => template('pentaho/pentaho_context.xml.erb'),
			mode => 755,
			owner => "tomcat",
			group => "pentaho",
			require => [Package["pentaho-biserver"], Exec["remove dud configs"], Group["pentaho"]],
			#File["/srv/tomcat/pentaho_biserver/conf/",
			#"/srv/tomcat/pentaho_biserver/conf/Catalina/",
			#"/srv/tomcat/pentaho_biserver/conf/Catalina/localhost/"]],
			notify => Service["tomcat-pentaho_biserver"],
			replace => false,
	}
	#pentaho/WEB-INF/web.xml
	$webtemplate = $pentaho_enterprise ? {
		true => "pentaho/enterprise_web.xml.erb",
		default => "pentaho/pentaho_web.xml.erb",
	}

	file {
		'/srv/tomcat/pentaho_biserver/webapps/pentaho/WEB-INF/web.xml' :
			ensure => present,
			content => template("$webtemplate"),
			mode => 755,
			owner => "tomcat",
			group => "pentaho",
			notify => Service["tomcat-pentaho_biserver"],
			require => [Package["pentaho-biserver"], Exec["remove dud configs"], Group["pentaho"]],
			replace => false,
	}

	#pentaho-solutions/system/applicationContext-spring-security-hibernate.properties
	file {
		'/opt/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties' :
			ensure => present,
			content =>
			template('pentaho/solution_applicationContext-spring-security-hibernate.properties.erb'),
			mode => 755,
			owner => "tomcat",
			group => "pentaho",
			notify => Service["tomcat-pentaho_biserver"],
			require => [Package["pentaho-biserver"], Exec["remove dud configs"], Group["pentaho"]],
			replace => false,
	}

	#pentaho-solutions/system/hibernate/mysql5.hibernate.cfg.xml
	file {
		'/opt/pentaho-solutions/system/hibernate/mysql5.hibernate.cfg.xml' :
			ensure => present,
			content => template('pentaho/solution_mysql5.hibernate.cfg.xml.erb'),
			mode => 755,
			owner => "tomcat",
			group => "pentaho",
			require => [Package["pentaho-biserver"], Exec["remove dud configs"], Group["pentaho"]],
			notify => Service["tomcat-pentaho_biserver"],
			replace => false,
	}
	file {
		'/opt/pentaho-solutions/system/hibernate/hibernate-settings.xml' :
			ensure => present,
			content => template('pentaho/solution_hibernate-settings.xml.erb'),
			mode => 755,
			owner => "tomcat",
			group => "pentaho",
			notify => Service["tomcat-pentaho_biserver"],
			require => [Package["pentaho-biserver"], Exec["remove dud configs"], Group["pentaho"]],
			replace => false,
	}
	file {
		'/srv/tomcat/pentaho_biserver/webapps/pentaho/WEB-INF/classes/log4j.xml' :
			ensure => present,
			content => template('pentaho/pentaho_log4j.xml.erb'),
			mode => 755,
			owner => "tomcat",
			group => "pentaho",
			notify => Service["tomcat-pentaho_biserver"],
			require => [Package["pentaho-biserver"], Exec["remove dud configs"], Group["pentaho"]],
			replace => false,
	}
	
	  $publish_password = generate("/usr/bin/pwgen", 20, 1)
	
	file{'/opt/pentaho-solutions/system/publisher_config.xml':
	  content => template('pentaho/pentaho_publish.xml.erb'),
      mode => 755,
      owner => "tomcat",
      group => "pentaho",
      notify => Service["tomcat-pentaho_biserver"],
      require => [Package["pentaho-biserver"], Exec["remove dud configs"], Group["pentaho"]],
      replace => false,
	}
	if ($database == "mysql") {
	#mysql jar
		file {
			'/opt/apache-tomcat/lib/mysql-connector-java-5.1.17.jar' :
				ensure => present,
				owner => "tomcat",
			group => "pentaho",
				notify => Service["tomcat-pentaho_biserver"],
				source => "puppet:///modules/pentaho/mysql-connector-java-5.1.17.jar",
				mode => 755,
				require => [Package["pentaho-biserver"], Group["pentaho"]],

		}

		#c3p0 jar
		file {
			'/opt/apache-tomcat/lib/c3p0-0.9.1.2.jar' :
				ensure => present,
				owner => "tomcat",
			group => "pentaho",
				notify => Service["tomcat-pentaho_biserver"],
				source => "puppet:///modules/pentaho/c3p0-0.9.1.2.jar",
				mode => 755,
				require => [Package["pentaho-biserver"], Group["pentaho"]],
				
		}
		file {
      '/opt/administration-console/lib/c3p0-0.9.1.2.jar' :
        ensure => present,
        owner => "tomcat",
      group => "pentaho",
        notify => Service["jetty-pentaho_adminserver"],
        source => "puppet:///modules/pentaho/c3p0-0.9.1.2.jar",
        mode => 755,
        require => [Package["pentaho-biserver"], Group["pentaho"]],
        
    }
	}
		if ($database == "vectorwise") {
	#mysql jar
		file {
			'/opt/apache-tomcat/lib/mysql-connector-java-5.1.17.jar' :
				ensure => present,
				owner => "tomcat",
			group => "pentaho",
				notify => Service["tomcat-pentaho_biserver"],
				source => "puppet:///modules/pentaho/mysql-connector-java-5.1.17.jar",
				mode => 755,
				require => [Package["pentaho-biserver"], Group["pentaho"]],

		}

		#c3p0 jar
		file {
			'/opt/apache-tomcat/lib/c3p0-0.9.1.2.jar' :
				ensure => present,
				owner => "tomcat",
			group => "pentaho",
				notify => Service["tomcat-pentaho_biserver"],
				source => "puppet:///modules/pentaho/c3p0-0.9.1.2.jar",
				mode => 755,
				require => [Package["pentaho-biserver"], Group["pentaho"]],
				
		}
		
		    file {
      '/opt/administration-console/lib/c3p0-0.9.1.2.jar' :
        ensure => present,
        owner => "tomcat",
      group => "pentaho",
        notify => Service["jetty-pentaho_adminserver"],
        source => "puppet:///modules/pentaho/c3p0-0.9.1.2.jar",
        mode => 755,
        require => [Package["pentaho-biserver"], Group["pentaho"]],
        
    }
    file {  "tomcat iijdbc":
      path => '/opt/apache-tomcat/lib/iijdbc.jar',
      ensure => present,
      owner => "tomcat",
      group => "pentaho",
      source => "puppet:///modules/pentaho/iijdbc.jar",
      require => [Package["pentaho-biserver"], Group["pentaho"]],
      mode => 755,
  }
      file {  "admin iijdbc":
      path => '/opt/administration-console/jdbc/iijdbc.jar',
      ensure => present,
      owner => "tomcat",
      group => "pentaho",
      source => "puppet:///modules/pentaho/iijdbc.jar",
      require => [Package["pentaho-biserver"], Group["pentaho"]],
      mode => 755,
  }
  
	}
	if ($database == "postgresql") {
		file {
			'/opt/apache-tomcat/lib/postgresql-9.1-901.jdbc4.jar' :
				ensure => present,
				owner => "tomcat",
				group => "pentaho",
				source => "puppet:///modules/pentaho/postgresql-9.1-901.jdbc4.jar",
				mode => 755,
				require => [Package["pentaho-biserver"], Group["pentaho"]],
		}
	}
}
