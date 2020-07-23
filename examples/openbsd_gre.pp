bsd::network::interface { 'gre0':
  description => 'Tunnel interface',
  values      => [
    '172.16.0.1 172.16.0.2 netmask 0xffffffff link0 up',
    'tunnel 1.2.3.4 5.6.7.8',
  ],
}
