bsd::network::interface { 're0':
  description => 'Primary interface',
  values      => ['dhcp'],
}

bsd::network::interface { 'em0':
  description => 'Other interface',
  values      => ['10.0.0.1/24'],
}
