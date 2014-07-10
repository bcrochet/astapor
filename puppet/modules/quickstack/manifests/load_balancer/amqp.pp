class quickstack::load_balancer::amqp (
  $frontend_host        = '',
  $backend_server_names = [],
  $backend_server_addrs = [],
  $port                 = '5672',
  $backend_port         = '15672',
  $mode                 = 'tcp',
  $timeout              = '120s',
  $log                  = 'tcplog',
) {
  include 'stdlib'
  include quickstack::load_balancer::common

  $common_options = {
    'option'  => ["$log"],
    'timeout' => [ "client $timeout",
                   "server $timeout", ],
  }

  if (map_params('include_rabbitmq') == 'true') {
    $listen_options = {
      'balance' => 'roundrobin',
    }
  } else {
    $listem_options = {
      'stick-table' => 'type ip size 2',
      'stick' => 'on dst',
    }
  }

  $options = merge($common_options, $listen_options)

  quickstack::load_balancer::proxy { 'amqp':
    addr                 => "$frontend_host",
    port                 => "$port",
    mode                 => "$mode",
    listen_options       => $options,
    member_options       => [ 'check' ],
    backend_server_addrs => $backend_server_addrs,
    backend_server_names => $backend_server_names,
    backend_port         => $backend_port,
  }
}
