class pentaho::git {
	include git 
	group {
		"pentaho" :
			ensure => "present",
	}
	user {
		"git" :
			ensure => present,
			comment => "Git User",
			shell => "/bin/bash",
			home => "/srv/git",
			require => Group[pentaho],
	}
	User <| title == tomcat |> {
		groups +> ["pentaho"]
	}
}