# A static network configuration
class { 'bsd::network':
  v4gateway => $v4gateway,
  v6gateway => $v6gateway,
}
