# galera_config.pp
# Manage galera cluster specific config.
#
# https://mariadb.com/kb/en/mariadb/mariadb-documentation/replication-cluster-multi-master/galera/getting-started-with-mariadb-galera-cluster
# https://mariadb.com/kb/en/mariadb/mariadb-documentation/replication-cluster-multi-master/galera/galera-cluster-system-variables
# http://tecadmin.net/setup-mariadb-galera-cluster-5-5-in-centos-rhel
# http://galeracluster.com/documentation-webpages/configuration.html
#
#

class mariadb::cluster::galera_config {

  validate_absolute_path($mariadb::cluster::config_dir)
  validate_re($mariadb::cluster::wsrep_sst_method, '^(mysqldump|rsync|rsync_wan|xtrabackup|xtrabackup-v2)$')

  if $mariadb::cluster::wsrep_cluster_address {
    $_wsrep_cluster_address = $mariadb::cluster::wsrep_cluster_address
  } elsif is_array($mariadb::cluster::wsrep_cluster_peers) {
    $_wsrep_cluster_peers = join($mariadb::cluster::wsrep_cluster_peers, ',')
    $_wsrep_cluster_address = "'gcomm://${_wsrep_cluster_peers}'"
  } else {
    $_wsrep_cluster_address = undef
  }
  if $mariadb::cluster::wsrep_sst_password != 'UNSET' {
    $_wsrep_sst_auth = "'${mariadb::cluster::wsrep_sst_user}:${mariadb::cluster::wsrep_sst_password}'"
  } else {
    $_wsrep_sst_auth = undef
  }

  $options_from_params = {
    'mysqld' => {
      'wsrep_cluster_address' => $_wsrep_cluster_address,
      'wsrep_cluster_name'    => $mariadb::cluster::wsrep_cluster_name,
      'wsrep_sst_auth'        => $_wsrep_sst_auth,
      'wsrep_sst_method'      => $mariadb::cluster::wsrep_sst_method,
    },
  }
  $options = mysql_deepmerge($options_from_params, $mariadb::cluster::galera_options)
  $includedir = false

  if $mariadb::cluster::wsrep_sst_method in ['xtrabackup', 'xtrabackup-v2'] {
    package { 'percona-xtrabackup':
      ensure => installed,
      before => File["${mariadb::cluster::config_dir}/cluster.cnf"],
    }
  }

  file { "${mariadb::cluster::config_dir}/cluster.cnf":
    ensure  => file,
    owner   => 'root',
    group   => $mysql::params::root_group,
    mode    => '0644',
    content => template('mysql/my.cnf.erb'),
  }
}