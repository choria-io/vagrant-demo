class roles::puppetserver {
  include profiles::common
  include profiles::puppetserver
  include profiles::network_broker
}
