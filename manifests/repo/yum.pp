# yum.pp
# Manage the mariadb yum repo.
#

class mariadb::repo::yum {
  $version         = $mariadb::repo::repo_version
  $os              = $mariadb::repo::os
  $arch            = $mariadb::repo::arch
  $module_hotfixes = $mariadb::repo::module_hotfixes

  yumrepo { 'mariadb':
    baseurl         => "http://yum.mariadb.org/${version}/${os}${::operatingsystemmajrelease}-${arch}",
    descr           => 'MariaDB',
    enabled         => '1',
    gpgcheck        => '1',
    module_hotfixes => $module_hotfixes,
    gpgkey          => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
  }
  # lint:ignore:spaceship_operator_without_tag
  Yumrepo['mariadb'] -> Package<| |>
  # lint:endignore
}
