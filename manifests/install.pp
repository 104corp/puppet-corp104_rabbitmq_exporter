# Class: corp104_rabbitmq_exporter::install
#
# This module manages rabbitmq_exporter install
#
class corp104_rabbitmq_exporter::install (
  String    $package_name      = $corp104_rabbitmq_exporter::package_name,
  String    $version           = $corp104_rabbitmq_exporter::version,
  String    $package_ensure    = 'installed',
  String    $package_dir       = '/opt',
  String    $install_method    = 'url',
  String    $download_url      = $corp104_rabbitmq_exporter::download_url,
  String    $download_extension = 'tar.gz',
  String    $bin_dir           = $corp104_rabbitmq_exporter::bin_dir,
  String    $service_name      = $corp104_rabbitmq_exporter::service_name,
  String    $http_proxy        = $corp104_rabbitmq_exporter::http_proxy,
) {

  $proxy_server = empty($http_proxy) ? {
    true    => undef,
    default => $http_proxy,
  }
  # rabbitmq_exporter-1.0.0-RC5.linux-amd64.tar.gz
  $install_dir = "${package_dir}/${package_name}-${version}.linux-${facts['architecture']}"

  case $install_method {
    'url': {
      file { $install_dir:
        ensure => 'directory',
        owner  => 'root',
        group  => 0, # 0 instead of root because OS X uses "wheel".
        mode   => '0555',
      }
      -> archive { "/tmp/${package_name}-${version}.${download_extension}":
        ensure          => present,
        source          => $download_url,
        creates         => "${install_dir}/${package_name}",
        extract         => true,
        extract_path    => $package_dir,
        proxy_server    => $proxy_server,
        checksum_verify => false,
        cleanup         => true,
      }
      -> file {
        "${install_dir}/${package_name}":
          owner => 'root',
          group => 0, # 0 instead of root because OS X uses "wheel".
          mode  => '0555';
        "${bin_dir}/${service_name}":
          ensure => link,
          notify => Service[$service_name],
          target => "${install_dir}/${package_name}",
      }
    }
    'package': {
      package { $package_name:
        ensure => $package_ensure,
      }
    }
    default: {
      fail("The provided install method ${install_method} is invalid")
    }
  }
}
