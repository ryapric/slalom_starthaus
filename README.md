MySQL cross-server dump-and-migrate utility
===========================================

As an example, this shell script could be used like the following, to copy an
entire DB named "example" from a sandbox server (sandbox.app.co) to the
production server (prod.app.co):

    ./mysqlcopy.bash -d example -u username -f sandbox.app.co -t prod.app.co

Where:

* d = Database name
* u = MySQL server (SSH) username
* f = 'From' server address
* t = 'To' server address

Note that local MySQL access requires a separate MySQL User and Password to be
passed server-side, but this script expects that there exists a protected
`.my.cnf` file in the remote user's working directory (this is also more secure
than passing password as plaintext to the command line).

The assumption is that the user as defined in the `-u` argument has SSH access
to *all* servers.
