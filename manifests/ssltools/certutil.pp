# type to append cert to nssdb
define certs::ssltools::certutil (
  Stdlib::Absolutepath $nss_db_dir,
  Stdlib::Absoluatepath $client_cert,
  String $cert_name = $title,
  Boolean $refreshonly = true,
  Boolean $trustargs = ',,',
) {
  include certs::ssltools::nssdb

  # lint:ignore:relative_classname_reference
  Class['::certs::ssltools::nssdb'] ->
  # lint:endignore
  exec { "delete ${cert_name}":
    path        => ['/bin', '/usr/bin'],
    command     => "certutil -D -d ${nss_db_dir} -n '${cert_name}'",
    onlyif      => "certutil -L -d ${nss_db_dir} | grep '^${cert_name}\\b'",
    logoutput   => true,
    refreshonly => $refreshonly,
  } ->
  exec { $cert_name:
    path        => ['/bin', '/usr/bin'],
    command     => "certutil -A -d '${nss_db_dir}' -n '${cert_name}' -t '${trustargs}' -a -i '${client_cert}' -f '${certs::ssltools::nssdb::nss_db_password_file}'",
    unless      => "certutil -L -d ${nss_db_dir} | grep '^${cert_name}\\b'",
    logoutput   => true,
    refreshonly => $refreshonly,
  }
}
