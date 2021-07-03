Sqitch Homebrew Tap
===================

This Homebrew tap provides a formula for [Sqitch](https://sqitch.org/), a
database schema development and change management system. If you'd like to try
Sqitch and use [Homebrew](https://brew.sh/), this will be the simplest way to
get it installed so you can get to work.

First, use this command to set up the Sqitch Homebrew tap:

    brew tap sqitchers/sqitch

Now you can install Sqitch with your choice of database support:

    brew install sqitch --with-postgres-support --with-sqlite-support

If you see an error about missing headers on Mojave, like
`fatal error: 'EXTERN.h' file not found`, install the headers like so and try
again:

    sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /

Supported Database Engines
--------------------------

Mix and match support as you prefer via the following options:

### `--with-postgres-support`

    brew install sqitch --with-postgres-support
    brew install sqitch --with-postgres-support --without-postgresql

Support for managing [PostgreSQL](https://www.postgresql.org) databases. This
feature optionally depends on the Homebrew PostgreSQL server, both to build the
necessary database driver at build time, and to use `psql` client to manage
databases at runtime. If you have your own PostgreSQL install and don't need the
Homebrew instance, pass `--without-postgresql` to prevent Homebrew from
installing it --- although then you might need to tell the installer where
to find things. To quote from the
[DBD::Pg README](https://github.com/bucardo/dbdpg#readme):

> By default Makefile.PL uses App::Info to find the location of the
> PostgreSQL library and include directories. However, if you want to
> control it yourself, define the environment variables `POSTGRES_INCLUDE`
> and `POSTGRES_LIB`, or define just `POSTGRES_HOME`. Note that if you have
> compiled PostgreSQL with SSL support, you must define the `POSTGRES_LIB`
> environment variable and add "-lssl" and "-lcrypto" to it, like this:
>
>     export POSTGRES_LIB="/usr/local/pgsql/lib -lssl -lcrypto"

If, for example, you use [pgenv](https://github.com/theory/pgenv) to
install PostgreSQL on your system, you'd need to export something like:

export POSTGRES_LIB="$HOME/.pgenv/pgsql/lib -lssl -lcrypto"
export POSTGRES_INCLUDE="$HOME/.pgenv/pgsql/include"

Then build with `--with-std-env` to ensure that Homebrew will use the
environment variables:

    brew install sqitch --with-std-env --with-postgres-support --without-postgresql

### `--with-sqlite-support`

    brew install sqitch --with-sqlite-support
    brew install sqitch --with-sqlite-support --without-sqlite

Support for managing [SQLite](https://sqlite.org/) databases. This feature
optionally depends on the Homebrew SQLite build for the use of the `sqlite3`
client at runtime. If you have your own install or just want to rely on the
macOS system-provided SQLite, pass `--without-sqlite` to prevent Homebrew from
installing it.

### `--with-mysql-support`

    brew install sqitch --with-mysql-support
    brew install sqitch --with-mysql-support --without-mysql

Support for managing [MySQL](https://www.mysql.com) databases. This feature
optionally depends on the Homebrew MySQL server, both to build the necessary
database driver at build time, and to use the `mysql` client to manage databases
at runtime. If you have your own MySQL install and don't need the Homebrew
instance, pass `--without-mysql`  to prevent Homebrew from installing it.

### `--with-firebird-support`

    brew install sqitch --with-firebird-support

Support for managing [Firebird](https://www.firebirdsql.org) databases. This
feature depends on the presence of a Firebird database installation, both to
build the necessary database driver at build time, and to use the `isql` client
to manage databases at runtime. Alas, there appears to be no Homebrew formula
for Firebird, so you'll have to manually
[download](https://www.firebirdsql.org/en/server-packages/) and install it
before installing Sqitch with Firebird support. If no Firebird driver library is
found, the build will fail.

### `--with-oracle-support`

    export HOMEBREW_ORACLE_HOME=/oracle/instantclient_12_2
    brew install sqitch --with-oracle-support

Support for managing [Oracle](https://www.oracle.com/database/) databases. This
feature depends on the presence of the
[Oracle Instant Client](https://www.oracle.com/technetwork/topics/intel-macsoft-096467.html)
Basic and SDK packages to build the necessary database driver at build time,
plus the SQL\*Plus package to manage databases at runtime. If no Instant Client
files are found, the build will fail.

Sadly, [System Integrity Protection](https://support.apple.com/en-us/HT204899)
must be disabled in order to build Sqitch with Oracle support. This is to allow
the setting of the `$DYLD_LIBRARY_PATH` environment variable, which is required
for Oracle support in Sqitch.
[Here's how](https://www.imore.com/how-turn-system-integrity-protection-macos).

With SIP disabled, set `$HOMEBREW_ORACLE_HOME` to the full path to the directory
for Instant Client. This will allow the build to find the libraries necessary to
complete the build with Oracle support. To use Sqitch with Oracle, you will
need to set the `$ORACLE_HOME` and `$DYLD_LIBRARY_PATH` variables to point to
the Instant Client, something like:

    export ORACLE_HOME=/usr/local/instantclient_12_2
    export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$ORACLE_HOME

### `--with-vertica-support`

    brew install sqitch --with-vertica-support
    brew install sqitch --with-vertica-support --without-libiodbc

Support for managing [Vertica](https://www.vertica.com) databases. This
feature depends on the presence of the Vertica ODBC driver and the `vsql`
client in order to manage Vertica databases. You will need to
[download](https://my.vertica.com/download/vertica/client-drivers/) and
install the ODBC and `vsql` packages for macOS prior to using Sqitch to
manage Vertica databases.

Furthermore, the Sqitch Vertica build optionally requires the Homebrew
`libiodbc` package to build the ODBC driver. If you have your own build of iODBC
or unixODBC that you'd rather use, pass `--without-libiodbc` to prevent Homebrew
from installing it.

### `--with-exasol-support`

    brew install sqitch --with-exasol-support
    brew install sqitch --with-exasol-support --without-libiodbc

Support for managing [Exasol](https://www.exasol.com) databases. This feature
depends on the presence of the Exasol ODBC driver and the `EXAplus` client in
order to manage Exasol databases. You will need to
[download](https://www.exasol.com/portal/display/DOWNLOAD/) and install the ODBC
and EXAplus packages for macOS prior to using Sqitch to manage Exasol databases.

Furthermore, the Sqitch Exasol build optionally requires the Homebrew `libiodbc`
package to build the ODBC driver. f you have your own build of iODBC or unixODBC
that you'd rather use, pass `--without-libiodbc` to prevent Homebrew from
installing it.

### `--with-snowflake-support`

    brew install sqitch --with-snowflake-support
    brew install sqitch --with-snowflake-support --without-libiodbc

Support for managing [Snowflake](https://www.snowflake.com) databases. This
feature depends on the presence of the Snowflake ODBC driver and the `snowsql`
client in order to manage Snowflake databases. You will need to download,
install and configure the
[ODBC driver](https://docs.snowflake.net/manuals/user-guide/odbc-download.html)
and
[SnowSQL](https://docs.snowflake.net/manuals/user-guide/snowsql-install-config.html)
client prior to using Sqitch to manage Snowflake databases.

Furthermore, the Sqitch Snowflake build optionally requires the Homebrew
`libiodbc` package to build the ODBC driver. f you have your own build of iODBC
or unixODBC that you'd rather use, pass `--without-libiodbc` to prevent Homebrew
from installing it.

Other Options
-------------

### `--with-std-env`

  brew install sqitch --with-std-env

Prefer versions of dependencies found in the path, even if they're not installed
by Homebrew. Essential if you want to use a library or database client that is
not installed by Homebrew and does not come with the system.

### `--HEAD`

    brew install sqitch --HEAD

Just want the latest from Git? Use the `--HEAD` option to clone Sqitch, install
configure-time dependencies in a temporary directory, and build Sqitch from the
main branch.

### `--devel`

    brew install sqitch --devel

Sometimes a pre-release version of Sqitch might be available for installation.
If so, the `--devel` option will build and install it.

### `--verbose`

    brew install sqitch --verbose

Turn on verbosity. Useful to get additional information in the event of
installation issues.

### `--quiet`

Turn off most output.

License
-------

The Sqitch Homebrew Tap formula is distributed as
[public domain](https://en.wikipedia.org/wiki/Public_Domain) software. Anyone
is free to copy, modify, publish, use, compile, sell, or distribute the
original Sqitch Homebrew Tap formulas, either in source code form or as a
compiled binary, for any purpose, commercial or non-commercial, and by any
means.

Author
------

[David E. Wheeler](https://justatheory.com/)
