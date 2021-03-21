# === Class: teleport
#
# Install, configures and manages teleport
#
# === Parameters
#
# [*version*]
#  Version of teleport to download
#
# [*archive_path*]
#  Where to download the teleport tarball
#
# [*extract_path*]
#  Directory to extract teleport
#
# [*bin_dir*]
#  Where to symlink teleport binaries
#
# [*assets_dir*]
#  Where to sylink the teleport web assets
#
# [*nodename*]
#  Teleport nodename.
#  Defaults to $::fqdn fact
#
# [*auth_type*]
#  default authentication type. possible values are 'local', 'oidc' and 'saml'
#  only local authentication (Teleport's own user DB) is supported in the open
#  source version
#  Defaults to 'local'
#
# [*auth_second_factor*]
#  Second_factor can be off, otp, or u2f
#  Defaults to 'otp'
#
# [*auth_u2f_app_id*]
#  app_id must point to the URL of the Teleport Web UI (proxy) accessible
#  by the end users. Only used if auth_second_factor is set to 'u2f'
#  Defaults to 'https://localhost:3080'
#
# [*auth_u2f_facets*]
#  facets must list all proxy servers if there are more than one deployed. Type array.
#  Only used if auth_second_factor is set to 'u2f'
#  Defaults to ['https://localhost:3080']
#
# [*data_dir*]
#  Teleport data directory
#  Defaults to undef (meaning teleport uses its
#  default of '/var/lib/teleport')
#
# [*auth_token*]
#  The auth token to use when joining the cluster
#  Defaults to undef
#
# [*auth_cluster_name*]
#  Optional "cluster name" is needed when configuring trust between multiple
#  auth servers. A cluster name is used as part of a signature in certificates
#  generated by this CA.
#
#  By default an automatically generated GUID is used.
#
#  IMPORTANT: if you change cluster_name, it will invalidate all generated
#  certificates and keys (may need to wipe out /var/lib/teleport directory)
#  Defaults to undef
#
# [*advertise_ip*]
#  When running in NAT'd environments, designates
#  an IP for teleport to advertise.
#  Defaults to undef
#
# [*storage_backend*]
#  Which storage backend to use.
#  Defaults to undef (meaning teleport uses its
#  default of boltdb
#
# [*storage_options*]
#  Extra options for some storage backends, like DynamoDB.
#  Defaults to {}
#
# [*max_connections*]
#  Configure max connections for teleport
#  Defaults to 100
#
# [*max_users*]
#  Teleport max users
#  Defaults to 250
#
# [*log_dest*]
#  Log destination
#  Defaults to stderr
#
# [*log_level*]
#  Log output level
#  Defaults to "ERROR"
#
# [*config_path*]
#  Path to config file for teleport
#  Defaults to /etc/teleport.yaml
#
# [*auth_servers*]
#  An array of auth servers to connect to
#
# [*auth_enable*]
#  Whether to start the auth service
#  Defaults to false
#
# [*auth_listen_addr*]
#  Address to listen for auth_service
#
# [*auth_listen_port*]
#  Port to listen on for auth server
#
# [*auth_service_tokens*]
#  The provisioning tokens for the auth tokens
#  Defaults to an empty array
#
# [*ssh_enable*]
#  Whether to start SSH service
#  Defaults to true
#
# [*ssh_listen_addr*]
#  Address to listen on for SSH connections
#  Defaults to 0.0.0.0
#
# [*ssh_listen_port*]
#  Port to listen on for SSH connection
#
# [*labels*]
#  A hash of labels to assign to hosts
#
# [*ssh_label_commands*]
#  List of the commands to periodically execute. Their output will be used as node labels.
#  See "Labeling Nodes" section below for more information.
#  Defaults to [{
#    name    => 'arch',
#    command => '[uname, -p]',
#    period  => '1h0m0s',
#  }]
#
# [*ssh_permit_user_env*]
#  enables reading ~/.tsh/environment before creating a session. by default
#  set to false, can be set true here or as a command line flag.
#  Defaults to false
#
# [*proxy_enable*]
#  Where to start the proxy service
#  Defaults to false
#
# [*proxy_listen_addr*]
#  Address to listen on for proxy
#
# [*proxy_listen_port*]
#  Port to listen on for proxy connection
#
# [*proxy_tunnel_listen_addr*]
#  Reverse tunnel listening address. An auth server (CA) can establish an
#  outbound (from behind the firewall) connection to this address.
#  This will allow users of the outside CA to connect to behind-the-firewall
#  nodes.
#  Defaults to '127.0.0.1'
#
# [*proxy_tunnel_listen_port*]
#  Reverse tunnel listening port.
#  Defaults to 3024
#
# [*proxy_web_listen_address*]
#  Address to listen on for web proxy
#
# [*proxy_web_listen_port*]
#  Port to listen on for web proxy connections
#
# [*proxy_ssl*]
#  Enable or disable SSL support
#  Default is false
#
# [*proxy_ssl_key*]
#  Path to SSL key for proxy
#
# [*proxy_ssl_cert*]
#  Path to SSL cert for proxy
#
# [*init_style*]
#  Which init system to use to start the service. Currently only
#  systemd is supported
#
# [*manage_service*]
#  Whether puppet should manage and configure the service
#
# [*service_ensure*]
#  State of the teleport service
#
# [*service_enable*]
#  Whether the service should be enabled on startup
#
class teleport (
  $version                  = $teleport::params::version,
  $archive_path             = $teleport::params::archive_path,
  $extract_path             = "/opt/teleport-${version}",
  $bin_dir                  = $teleport::params::bin_dir,
  $assets_dir               = $teleport::params::assets_dir,
  $nodename                 = $teleport::params::nodename,
  $auth_type                = $teleport::params::auth_type,
  $auth_second_factor       = $teleport::params::auth_second_factor,
  $auth_u2f_app_id          = $teleport::params::auth_u2f_app_id,
  $auth_u2f_facets          = $teleport::params::auth_u2f_facets,
  $auth_cluster_name        = $teleport::params::auth_cluster_name,
  $data_dir                 = undef,
  $auth_token               = undef,
  $advertise_ip             = undef,
  $storage_backend          = undef,
  $storage_options          = {},
  $max_connections          = 1000,
  $max_users                = 250,
  $log_dest                 = 'stderr',
  $log_level                = 'ERROR',
  $config_path              = $teleport::params::config_path,
  $auth_servers             = ['127.0.0.1:3025'],
  $auth_enable              = false,
  $auth_listen_addr         = '127.0.0.1',
  $auth_listen_port         = '3025',
  $auth_service_tokens      = [],
  $ssh_enable               = true,
  $ssh_listen_addr          = '0.0.0.0',
  $ssh_listen_port          = '3022',
  $labels                   = {},
  $ssh_label_commands       = $teleport::params::ssh_label_commands,
  $ssh_permit_user_env      = $teleport::params::ssh_permit_user_env,
  $proxy_enable             = false,
  $proxy_listen_addr        = '127.0.0.1',
  $proxy_listen_port        = '3023',
  $proxy_tunnel_listen_addr = $teleport::params::proxy_tunnel_listen_addr,
  $proxy_tunnel_listen_port = $teleport::params::proxy_tunnel_listen_port,
  $proxy_web_listen_addr    = '127.0.0.1',
  $proxy_web_listen_port    = '3080',
  $proxy_ssl                = false,
  $proxy_ssl_key            = undef,
  $proxy_ssl_cert           = undef,
  $init_style               = $teleport::params::init_style,
  $manage_service           = true,
  $service_ensure           = 'running',
  $service_enable           = true
) inherits teleport::params {

  validate_array($auth_servers)
  validate_array($ssh_label_commands)
  validate_array($auth_u2f_facets)
  validate_hash($storage_options)
  validate_bool($auth_enable)
  validate_bool($ssh_permit_user_env)
  validate_bool($ssh_enable)
  validate_hash($labels)
  validate_bool($proxy_enable)
  validate_bool($proxy_ssl)
  validate_bool($manage_service)
  validate_re($service_ensure, '^(running|stopped)$')
  validate_bool($service_enable)
  validate_array($auth_service_tokens)

  anchor { 'teleport_first': }
  ->  class { 'teleport::install': }
  ->  class { 'teleport::config': }
  ->  class { 'teleport::service': }
  ->  anchor { 'teleport_final': }

}
