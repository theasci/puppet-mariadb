# params.pp
# Set up MariaDB Cluster parameters defaults etc.
#

class mariadb::params {
  include '::mysql::params'

  #### init vars ####
  $manage_user     = false
  $manage_timezone = false
  $manage_repo     = true
  $repo_version    = '10.1'
  $auth_pam        = true
  $auth_pam_plugin = 'auth_pam.so'

  if ($::osfamily == 'RedHat') and (versioncmp($::operatingsystemrelease, '6.0') >= 0) {
    #### client specific vars ####
    # client.pp
    $client_package_name    = 'MariaDB-client'
    $shared_package_name    = 'MariaDB-shared'
    $devel_package_name     = 'MariaDB-devel'
    $client_default_options = {
      'client' => {
        'port' => '3306',
      },
      'mysqldump' => {
        'max_allowed_packet' => '16M',
        'quick'              => true,
        'quote-names'        => true,
      },
    }

    #### cluster specific vars ####
    # user.pp
    $user    = 'mysql'
    $comment = 'MySQL server'
    $uid     = 494
    $gid     = 494
    $home    = '/var/lib/mysql'
    $shell   = '/sbin/nologin'
    $group   = 'mysql'
    $groups  = undef

    # config.pp
    $log_error   = '/var/lib/mysql/mysqld.log'
    $config_file = '/etc/my.cnf.d/server.cnf'
    $includedir  = '' # lint:ignore:empty_string_assignment
    $config_dir  = '/etc/my.cnf.d'
    $pidfile     = '/var/lib/mysql/mysqld.pid'

    # server.pp
    $server_package_name    = 'MariaDB-server'
    $server_default_options = {
      'mysqld_safe' => {
        'log-error' => $log_error,
      },
      'mysqld' => {
        'log-error'             => $log_error,
        'pid-file'              => $pidfile,
        'innodb_file_per_table' => 'ON',
      },
    }

    # cluster.pp
    $cluster_package_name    = 'MariaDB-Galera-server'
    $cluster_default_options = {
      'mysqld_safe' => {
        'log-error' => $log_error,
      },
      'mysqld' => {
        'bind-address'          => '0.0.0.0',
        'performance_schema'    => 'ON',
        'log-error'             => $log_error,
        'pid-file'              => $pidfile,
        'query_cache_limit'     => undef,
        'query_cache_size'      => undef,
        'innodb_file_per_table' => 'ON',
      },
    }

    # wsrep patch config
    $wsrep_cluster_address       = undef
    $wsrep_cluster_peers         = undef
    $wsrep_cluster_name          = undef
    $wsrep_sst_user              = 'wsrep_sst'
    $wsrep_sst_password          = 'UNSET'
    $wsrep_sst_method            = 'mysqldump'
    $root_password               = 'UNSET'
    $galera_default_options      = {
      'mysqld' => {
        'wsrep_on'                        => 'ON',
        'wsrep_provider'                  => '/usr/lib64/galera/libgalera_smm.so',
        'wsrep_node_name'                 => $::hostname,
        'wsrep_slave_threads'             => '1', #$::processorcount * 2
        'wsrep_node_address'              => $::ipaddress,
        'wsrep_node_incoming_address'     => $::ipaddress,
        'binlog_format'                   => 'ROW',
        'default_storage_engine'          => 'InnoDB',
        'innodb_autoinc_lock_mode'        => '2',
        'innodb_doublewrite'              => '1',
        'query_cache_size'                => '0',
        'innodb_flush_log_at_trx_commit'  => '2',
        '#innodb_locks_unsafe_for_binlog' => '1',
      },
    }
  } elsif ($::osfamily == 'Debian') and (
    (($::operatingsystem == 'Debian') and (versioncmp($::operatingsystemrelease, '7.0') >= 0)) or
    (($::operatingsystem == 'Ubuntu') and (versioncmp($::operatingsystemrelease, '12.0') >= 0))
  ) {
    # stub!
  } else {
    fail("The ${module_name} module is not supported on a ${::osfamily} based system with version ${::operatingsystemrelease}.")
  }
}