require 'formula'

class Sqitch < Formula
  class Perl510 < Requirement
    fatal true

    satisfy do
      `perl -E 'print $]'`.to_f >= 5.01000
    end

    def message
      "Sqitch requires Perl 5.10.0 or greater."
    end
  end

  homepage   'https://sqitch.org/'
  version    '0.9998'
  url        "http://cpan.cpantesters.org/authors/id/D/DW/DWHEELER/App-Sqitch-#{stable.version}.tar.gz"
  sha256     'a0e39514470256cd2953cd6c13e0429db9cb904bf1fe52c01238d35d2c2f4c6e'
  head       'https://github.com/sqitchers/sqitch.git', :branch => 'bundle' # XXX remove branch
  depends_on Perl510
  depends_on 'cpanminus' => :build
  bottle     :unneeded

  option 'with-postgres-support',  "Support for managing PostgreSQL databases"
  option 'with-sqlite-support',    "Support for managing SQLite databases"
  option 'with-mysql-support',     "Support for managing MySQL databases"
  option 'with-firebird-support',  "Support for managing Firbird databases"
  option 'with-oracle-support',    "Support for managing Oracle databases"
  option 'with-vertica-support',   "Support for managing Vertica databases"
  option 'with-exasol-support',    "Support for managing Exasol databases"
  option 'with-snowflake-support', "Support for managing Snowflake databases"

  if build.head?
    depends_on 'gettext' => :build
  end

  if build.with? "postgres-support"
    depends_on 'postgresql' => :recommended
  end

  if build.with? "sqlite-support"
    depends_on 'sqlite' => :recommended
  end

  if build.with? "mysql-support"
    depends_on 'mysql' => :recommended
  end

  if build.with? "firebird-support"
    ohai "Firebird support requires the Firebird database and isql"
    ohai "  - Downloads: https://www.firebirdsql.org/en/server-packages/"
    ohai "  - isql Docs: https://firebirdsql.org/manual/isql.html"
  end

  if build.with? "oracle-support"
    ohai "Oracle support requires the Oracle Instant Client ODBC and SQL*Plus packages"
    ohai "  - Instant Client: http://www.oracle.com/technetwork/topics/intel-macsoft-096467.html"
    ohai "  - ODBC Docs: https://blogs.oracle.com/opal/installing-the-oracle-odbc-driver-on-macos"
  end

  if build.with? "vertica-support"
    depends_on "libiodbc" => :recommended
    ohai "Vertica support requires the Vertica ODBC driver and vsql"
    ohai "  - Downloads: https://my.vertica.com/download/vertica/client-drivers/"
    ohai "  - ODBC Docs: https://my.vertica.com/docs/9.1.x/HTML/index.htm#Authoring/ConnectingToVertica/InstallingDrivers/MacOSX/InstallingTheODBCDriverOnMacOSX.htm"
  end

  if build.with? "exasol-support"
    depends_on "libiodbc" => :recommended
    ohai "Exasol support requires the Exasol ODBC driver and exaplus"
    ohai "  - Downloads: https://www.exasol.com/portal/display/DOWNLOAD/"
    ohai "  - Docs: https://www.exasol.com/portal/pages/viewpage.action?pageId=4030482"
  end

  if build.with? "snowflake-support"
    depends_on "libiodbc" => :recommended
    ohai "Snowflake support requires the Snowflake ODBC driver and SnowSQL"
    ohai "  - ODBC Driver: https://docs.snowflake.net/manuals/user-guide/odbc-mac.html"
    okay "  - SnowSQL: https://docs.snowflake.net/manuals/user-guide/snowsql.html"
  end

  def install
    # Download Module::Build and Menlo::CLI::Compat.
    cpanmArgs = %W[-L instutil --quiet --notest];
    system 'cpanm', *cpanmArgs, 'Menlo::CLI::Compat', 'Module::Build'
    ENV['PERL5LIB'] = "#{buildpath}/instutil/lib/perl5"

    if build.head?
      # Download Dist::Zilla and plugins, then make and cd to a build dir.
      system 'cpanm', *cpanmArgs, 'Dist::Zilla';
      system 'dzil authordeps --missing | cpanm ' + cpanmArgs.join(' ')
      system 'dzil', 'build', '.brew'
      Dir.chdir '.brew'
    end

    # Pull together features.
    args = %W[Build.PL --install_base #{prefix} --etcdir #{etc}/sqitch]
    %w{postgres sqlite mysql firebird oracle vertica exasol snowflake}.each { |f|
      args.push("--with", f) if build.with? "#{ f }-support"
    }

    # Build and bundle (install).
    system "perl", *args
    system "./Build", "bundle"

    # Move the man pages from #{prefix}/man to #{prefix}/share/man.
    mkdir "#{prefix}/share"
    mv "#{prefix}/man", "#{prefix}/share/man"
  end
end
