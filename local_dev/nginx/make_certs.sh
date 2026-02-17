# mkcert can be installed on ubuntu by `apt install mkcert`


mkcert -install -cert-file "./icos-cp-local.pem" -key-file "./icos-cp-local-key.pem" datalocal.icos-cp.eu metalocal.icos-cp.eu datalocal.fieldsites.se metalocal.fieldsites.se localhost 127.0.0.1 ::1
# mkcert -install -cert-file ".//icos-fieldsites-local.pem" -key-file ".//icos-fieldsites-local-key.pem"  local.datalocal.fieldsites.se localhost 127.0.0.1 ::1
