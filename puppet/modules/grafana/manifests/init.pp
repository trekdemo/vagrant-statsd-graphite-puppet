class grafana(
  $version = '1.5.2',
  $port    = 80,
  ) {

  $grafana_url = "https://github.com/torkelo/grafana/releases/download/v${version}/grafana-${version}.tar.gz"

  exec { "${module_name} - download and extract release":
    command => "wget $grafana_url | tar xzf - -C /opt",
    creates => "/opt/grafana-${version}",
  } ->

  exec { "${module_name} - symlink release":
    command => "ln -snf /opt/grafana-${version} /opt/grafana-latest",
    creates => "/opt/grafana-latest",
  } ->

  file { '/etc/apache2/sites-available/grafana':
    content => '
Alias /grafana /opt/grafana-latest
<Directory /grafana>
     Order allow,deny
     Allow from all
</Directory> ',
    notify => Service["apache2"],
    require => Package["apache2"],
  } ->

  file { '/etc/apache2/sites-enabled/grafana':
    ensure => link,
    target => '/etc/apache2/sites-available/grafana',
    notify => Service['apache2'],
  }

}
