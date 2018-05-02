node default {
  include "roles::${facts['role']}"
}
