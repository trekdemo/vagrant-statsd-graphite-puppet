class grafana($version = '1.5.2', $port = 80) {

  $grafana_url = "https://github.com/torkelo/grafana/releases/download/v${version}/grafana-${version}.tar.gz"
  $grafana_latest = "/opt/grafana-latest"

  exec { "${module_name} - download and extract release":
    command => "wget -qO- $grafana_url | tar xzf - -C /opt",
    creates => "/opt/grafana-${version}",
  } ->

  exec { "${module_name} - symlink release":
    command => "ln -snf /opt/grafana-${version} ${grafana_latest}",
    creates => "${grafana_latest}",
  } ->

  exec { "${module_name} - create config":
    command => "cp ${grafana_latest}/config.sample.js ${grafana_latest}/config.js",
    creates => "${grafana_latest}/config.js",
  }

}
