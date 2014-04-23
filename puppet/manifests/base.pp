Exec {
  path => ["/usr/bin", "/usr/sbin", '/bin']
}

Exec["apt-get-update"] -> Package <| |>

exec { "apt-get-update" :
  command => "/usr/bin/apt-get update",
  require => File["/etc/apt/preferences"]
}

file { "/etc/apt/preferences" :
  source => "puppet://apt.preferences",
  ensure => present,
}

include carbon
include statsd
# include grafana
