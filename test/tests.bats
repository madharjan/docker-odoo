@test "checking process: odoo" {
  run docker exec odoo /bin/bash -c "ps aux | grep -v grep | grep 'python /opt/odoo/openerp-server'"
  [ "$status" -eq 0 ]
}

@test "checking process: odoo (disabled by DISABLE_ODOO)" {
  run docker exec odoo_no_default /bin/bash -c "ps aux | grep -v grep | grep 'python /opt/odoo/openerp-server'"
  [ "$status" -eq 1 ]
}

@test "checking request: status (website)" {
  run docker exec odoo /bin/bash -c "curl -I -s -L http://localhost:8069 | head -n 1 | cut -d$' ' -f2"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "checking request: content (website)" {
  run docker exec odoo /bin/bash -c "curl -s -L http://localhost:8069 | grep 'Acme Pte Ltd'"
  [ "$status" -eq 0 ]
}

@test "checking request: status (default)" {
  run docker exec odoo_default /bin/bash -c "curl -I -s -L http://localhost:8069 | head -n 1 | cut -d$' ' -f2"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "checking request: content (default)" {
  run docker exec odoo_default /bin/bash -c "curl -s -L http://localhost:8069 | grep 'Demo'"
  [ "$status" -eq 0 ]
}
