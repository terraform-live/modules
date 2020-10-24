#!/bin/bash

cat > index.html <<EOF
<h1>$This is the Day The Lord has Made</h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
EOF

nohup busybox httpd -f -p ${server_port} & > busybox.log 2>&1
