# == Define: createrepo
#
# createrepo creates yum repositories.
#
# === Parameters
#
# [*repository_dir*]
#   The path to the base directory of the repository. Here, or in subdirectories
#   you store the .rpm files. Default: /var/yumrepos/${name}
#
# [*repo_cache_dir*]
#   Path to a checksum directory. Makes updates to repository much faster.
#   Default: /var/cache/yumrepos/${name}
#
# [*repo_owner*]
#   Owner of the repository directory. Default: 'root'
#
# [*repo_group*]
#   Group of the repository directory. Default: 'root'
#
# [*cron_minute*]
#   Minute parameter for cron metadata update job. Default: '*/1'
#
# [*cron_hour*]
#   Hour parameter for cron metadata update job. Default: '*'
#
# === Variables
#
# None.
#
# === Examples
#
#  createrepo { 'yumrepo':
#    repository_dir => '/var/yumrepos/yumrepo',
#    repo_cache_dir => '/var/cache/yumrepos/yumrepo'
#  }
#
# === Authors
#
# Author Name <pall.valmundsson@gmail.com>
#
# === Copyright
#
# Copyright 2012, 2013 Pall Valmundsson, unless otherwise noted.
#
define createrepo (
    $repository_dir = "/var/yumrepos/${name}",
    $repo_cache_dir = "/var/cache/yumrepos/${name}",
    $repo_owner     = 'root',
    $repo_group     = 'root',
    $cron_minute    = '*/1',
    $cron_hour      = '*',
) {
    file { $repository_dir:
        ensure => directory,
        owner  => $repo_owner,
        group  => $repo_group,
        mode   => '0775',
    }

    file { $repo_cache_dir:
        ensure => directory,
        owner  => $repo_owner,
        group  => $repo_group,
        mode   => '0775',
    }

    if ! defined(Package['createrepo']) {
        package { 'createrepo':
            ensure => present,
        }
    }

    $createrepo_exec_name = "createrepo ${name} in ${repository_dir}"

    exec { $createrepo_exec_name:
        command => "/usr/bin/createrepo --database --changelog-limit 5 --cachedir ${repo_cache_dir} ${repository_dir}",
        require => [ Package['createrepo'], File[$repository_dir] ],
        user    => $repo_owner,
        group   => $repo_group,
        creates => "${repository_dir}/repodata",
    }

    cron { "update-createrepo-${name}":
        command => "/usr/bin/createrepo --update --cachedir ${repo_cache_dir} ${repository_dir}",
        user    => $repo_owner,
        minute  => $cron_minute,
        hour    => $cron_hour,
    }
}
