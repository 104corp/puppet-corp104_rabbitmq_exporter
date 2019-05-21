# Class: corp104_rabbitmq_exporter::service
#
# This module manages rabbitmq_exporter service
#
class corp104_rabbitmq_exporter::service (
  String $rabbit_url,
  String $rabbit_user,
  String $rabbit_password,
  String $queues_include_regex,
  String $queues_exclude_regex,
  String $vhosts_include_regex,
  String $vhosts_exclude_regex,
  Array[String] $rabbit_capabilities,
  Array[String] $rabbit_exporters,
  String    $user              = $corp104_rabbitmq_exporter::user,
  String    $group             = $corp104_rabbitmq_exporter::group,
  Boolean   $manage_user       = true,
  Array     $extra_groups      = [],
  Boolean   $manage_group      = true,
  String    $bin_dir           = $corp104_rabbitmq_exporter::bin_dir,
  String    $init_style        = $corp104_rabbitmq_exporter::init_style,
  String    $service_name      = $corp104_rabbitmq_exporter::service_name,
  String    $service_ensure    = 'running',
  Boolean   $service_enable    = true,
  Boolean   $manage_service    = true,
  Boolean   $restart_on_change = true,
  String    $extra_options     = '',
  Hash[String,Scalar] $extra_env_vars = $corp104_rabbitmq_exporter::extra_env_vars,
) {

  $notify_service = $restart_on_change ? {
    true    => Service[$service_name],
    default => undef,
  }

  $options = "${extra_options}"

  # Default Environment variables
  $env_vars = {
    'RABBIT_URL'          => $rabbit_url,
    'RABBIT_USER'         => $rabbit_user,
    'RABBIT_PASSWORD'     => $rabbit_password,
    'INCLUDE_QUEUES'      => $queues_include_regex,
    'SKIP_QUEUES'         => $queues_exclude_regex,
    'INCLUDE_VHOST'       => $vhosts_include_regex,
    'SKIP_VHOST'          => $vhosts_exclude_regex,
    'RABBIT_CAPABILITIES' => join($rabbit_capabilities, ','),
    'RABBIT_EXPORTERS'    => join($rabbit_exporters, ','),
  }

  $real_env_vars = merge($env_vars, $extra_env_vars)

  corp104_rabbitmq_exporter::daemon { $service_name:
    notify_service     => $notify_service,
    user               => $user,
    group              => $group,
    manage_user        => $manage_user,
    extra_groups       => $extra_groups,
    manage_group       => $manage_group,
    bin_dir            => $bin_dir,
    init_style         => $init_style,
    service_ensure     => $service_ensure,
    service_enable     => $service_enable,
    manage_service     => $manage_service,
    options            => $options,
    env_vars           => $real_env_vars,
  }
}
