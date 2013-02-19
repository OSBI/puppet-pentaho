class pentaho::postgresql {
    common::downloadfile {                                                                                                                     
    "create_repository_postgresql.sql.gz":                                                                                                                                
    site => "http://puppet.meteoritecloud.com",                                                                           
    cwd => "/srv/pentahodata/",                                                                            
    creates => "/srv/pentahodata/$name",        
    user => 'postgres'  ,
      require => File["/srv/pentahodata"],
      notify => Postgresql::Database["hibernate"],                                                     
}
	postgresql::user {
    "hibuser" :
      ensure => present,
      password => "password",
      superuser => false,
      createdb => false,
      createrole => false,
      require => Class["cloudbi::postgresql::configure"],
  } ->
	postgresql::database {
		"hibernate" :
			ensure => present,
			owner => hibuser,
			encoding => "UTF8",
			template => "template1",
			source => "/srv/pentahodata/create_repository_postgresql.sql.gz",
			overwrite => false,
	}
	

	
	postgresql::hba {
		"access to database hibuser" :
			ensure => present,
			type => 'local',
			database => 'hibernate',
			user => 'all',
			method => 'trust',
			require => Class["cloudbi::postgresql::configure"]
	}
		postgresql::hba {
		"access to quartz database pentaho_user" :
			ensure => present,
			type => 'local',
			database => 'quartz',
			user => 'all',
			method => 'trust',
      require => Class["cloudbi::postgresql::configure"]
			
	}
		postgresql::hba {
		"access to sampledata database hibuser" :
			ensure => present,
			type => 'local',
			database => 'sampledata',
			user => 'all',
			method => 'trust',
      require => Class["cloudbi::postgresql::configure"]
			
	}
	common::downloadfile {                                                                                                                     
    "create_quartz_postgresql.sql.gz":                                                                                                                                
    site => "http://puppet.meteoritecloud.com",                                                                           
    cwd => "/srv/pentahodata/",                                                                            
    creates => "/srv/pentahodata/$name",        
    user => 'postgres'  ,
    require => File["/srv/pentahodata"],
    notify => Postgresql::Database["quartz"],                                                        
}
	        postgresql::user {
                "pentaho_user" :
                        ensure => present,
                        password => "password",
                        superuser => false,
                        createdb => false,
                        createrole => false,
                        require => Class["cloudbi::postgresql::configure"],
        }

	postgresql::database {
		"quartz" :
			ensure => present,
			owner => pentaho_user,
			encoding => "UTF8",
			template => "template1",
			source => "/srv/pentahodata/create_quartz_postgresql.sql.gz",
			overwrite => false,
			require => [Postgresql::User["pentaho_user"],Exec["Create postgres user pentaho_user"],Class["cloudbi::postgresql::configure"],Common::Downloadfile["create_quartz_postgresql.sql.gz"]]
	}
	common::downloadfile {                                                                                                                     
    "create_sample_datasource_postgresql.sql.gz":                                                                                                                                
    site => "http://puppet.meteoritecloud.com",                                                                           
    cwd => "/srv/pentahodata/",                                                                            
    creates => "/srv/pentahodata/$name",        
    user => 'postgres'   ,           
   require => File["/srv/pentahodata"],
                                                
}

	exec {
		"Import dump into create datasource postgres db" :
			command =>
			"zcat /srv/pentahodata/create_sample_datasource_postgresql.sql.gz | psql hibernate",
			user => "postgres",
			require => [Postgresql::Database["hibernate"], Common::Downloadfile["create_sample_datasource_postgresql.sql.gz"]],
	}
	common::downloadfile {                                                                                                                     
    "load_sample_users_postgresql.sql.gz":                                                                                                                                
    site => "http://puppet.meteoritecloud.com",                                                                           
    cwd => "/srv/pentahodata/",                                                                            
    creates => "/srv/pentahodata/$name",        
    user => 'postgres'     ,
    require => File["/srv/pentahodata"],                                                     
}
	exec {
		"Import dump into load sample users postgres db" :
			command =>
			"zcat /srv/pentahodata/load_sample_users_postgresql.sql.gz | psql hibernate",
			user => "postgres",
			require => [Postgresql::Database["hibernate"],
			Common::Downloadfile["load_sample_users_postgresql.sql.gz"]],
	}
	common::downloadfile {                                                                                                                     
    "sampledata_postgresql.sql.gz":                                                                                                                                
    site => "http://puppet.meteoritecloud.com",                                                                           
    cwd => "/srv/pentahodata/",                                                                            
    creates => "/srv/pentahodata/$name",        
    user => 'postgres'    ,
    require => File["/srv/pentahodata"],
    notify => Postgresql::Database["sampledata"],                                                      
}
	postgresql::database {
		"sampledata" :
			ensure => present,
			owner => pentaho_user,
			encoding => "UTF8",
			template => "template1",
			source => "/srv/pentahodata/sampledata_postgresql.sql.gz",
			overwrite => false,
			require => [Postgresql::User["pentaho_user"],Exec["Create postgres user pentaho_user"],Class["cloudbi::postgresql::configure"],Common::Downloadfile["sampledata_postgresql.sql.gz"]]
	
}
}
