class pentaho::mysql {
	common::downloadfile {                                                                                                                     
	    "create_repository_mysql.sql":                                                                                                                                
	    site => "http://puppet.meteoritecloud.com/pentaho",                                                                           
	    cwd => "/srv/pentahodata/",                                                                            
	    creates => "/srv/pentahodata/$name",        
	    user => 'root'                                                          
	}->
         mysql::db { 'hibernate':
                user => 'hibuser',
                password => 'password',
                host => 'localhost',
		sql => '/srv/pentahodata/create_repository_mysql.sql'
        }
->
	common::downloadfile {                                                                                                                     
    "create_sample_datasource_mysql.sql":                                                                                                                                
    site => "http://puppet.meteoritecloud.com/pentaho",                                                                           
    cwd => "/srv/pentahodata/",                                                                            
    creates => "/srv/pentahodata/$name", 
    notify => Exec["importhibernate2"],      
    user => 'root'                                                          
}->
	exec {
		"importhibernate2" :
			cwd => "/tmp",
			command =>
			"mysql --defaults-file=/root/.my.cnf hibernate < /srv/pentahodata/create_sample_datasource_mysql.sql",
			refreshonly => true,
			require => [Common::Downloadfile["create_sample_datasource_mysql.sql"]],
	}
	common::downloadfile {                                                                                                                     
    "sampledata_mysql.sql":                                                                                                                                
    site => "http://puppet.meteoritecloud.com/pentaho",                                                                           
    cwd => "/srv/pentahodata/",                                                                            
    creates => "/srv/pentahodata/$name",        
    user => 'root' ,      
} ->

         mysql::db { 'sampledata':
                user => 'pentaho_user',
                password => 'password',
                host => 'localhost',
                sql => '/srv/pentahodata/sampledata_mysql.sql'
        }

	common::downloadfile {                                                                                                                     
    "create_quartz_mysql.sql":                                                                                                                                
    site => "http://puppet.meteoritecloud.com/pentaho",                                                                           
    cwd => "/srv/pentahodata/",                                                                            
    creates => "/srv/pentahodata/$name",        
    user => 'root',
}
->          mysql::db { 'quartz':
                user => 'quartz_user',
                password => 'password',
                host => 'localhost',
                sql => '/srv/pentahodata/create_quartz_mysql.sql'
        }

}
