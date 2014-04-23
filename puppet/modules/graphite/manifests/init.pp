class graphite {

  $build_dir = "/tmp"
  $webapp_url = "http://launchpad.net/graphite/0.9/0.9.9/+download/graphite-web-0.9.9.tar.gz"
  $webapp_loc = "$build_dir/graphite-web.tar.gz"

  exec { "download-graphite-webapp":
    command => "wget -O $webapp_loc $webapp_url",
    creates => "$webapp_loc"
  }

  exec { "unpack-webapp":
    command     => "tar -zxvf $webapp_loc",
    cwd         => $build_dir,
    subscribe   => Exec[download-graphite-webapp],
    refreshonly => true,
  }

  exec { "install-webapp":
    command => "python setup.py install",
    cwd     => "$build_dir/graphite-web-0.9.9",
    require => Exec[unpack-webapp],
    creates => "/opt/graphite/webapp"
  }

  file { [ "/opt/graphite/storage", "/opt/graphite/storage/whisper" ]:
    owner     => "www-data",
    mode      => "0775",
    subscribe => Exec["install-webapp"],
  }

  exec { "init-db":
    command   => "python manage.py syncdb --noinput",
    cwd       => "/opt/graphite/webapp/graphite",
    creates   => "/opt/graphite/storage/graphite.db",
    subscribe => File["/opt/graphite/storage"],
    require   => [
      File["/opt/graphite/webapp/graphite/initial_data.json"],
      Package["python-django-tagging"]
    ]
  }

  file { "/opt/graphite/webapp/graphite/initial_data.json" :
    require => File["/opt/graphite/storage"],
    ensure  => present,
    source  => "puppet:///modules/graphite/initial_data.json"
  }

  file { "/opt/graphite/storage/graphite.db" :
    owner => "www-data",
    mode => "0664",
    subscribe => Exec["init-db"],
    notify => Service["apache2"],
  }

  file { "/opt/graphite/storage/log/webapp/":
    ensure => "directory",
    owner => "www-data",
    mode => "0775",
    subscribe => Exec["install-webapp"],
  }

  file { "/opt/graphite/webapp/graphite/local_settings.py" :
    source => "puppet:///modules/graphite/local_settings.py",
    ensure => present,
    require => File["/opt/graphite/storage"]
 }

  file { "/etc/apache2/sites-available/default" :
    source  => 'puppet:///modules/graphite/apache_config.conf',
    notify  => Service["apache2"],
    require => Package["apache2"],
  }

  service { "apache2" :
    ensure  => "running",
    require => [
      File["/opt/graphite/storage/log/webapp/"],
      File["/opt/graphite/storage/graphite.db"]
    ]
  }

  package { [
      apache2, python-ldap, python-cairo, python-django, python-django-tagging, vim-tiny,
      python-simplejson, libapache2-mod-python, python-memcache, python-pysqlite2
    ]:
    ensure => latest;
  }

  package { "python-whisper" :
    ensure   => installed,
    provider => dpkg,
    source   => "/vagrant/python-whisper_0.9.9-1_all.deb",
    require  => Package['python-support']
  }

  package { "python-support":
    ensure => installed,
  }

}
