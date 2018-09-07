require 'formula'
require 'pp'

class Sqitch < Formula
  class Perl510Req < Requirement
    fatal true

    satisfy(build_env: false) { `perl -E 'print $]'`.to_f >= 5.01000 }

    def message
      "Sqitch requires Perl 5.10.0 or greater."
    end
  end

  class SnowflakeReq < Requirement
    @@dylib = "/opt/snowflake/snowflakeodbc/lib/universal/libSnowflake.dylib"
    @@binary = "/Applications/SnowSQL.app/Contents/MacOS/snowsql"
    @snowsql = false
    @driver = false
    fatal true
    download "https://docs.snowflake.net/manuals/user-guide/odbc-mac.html"

    def initialize(tags = [])
      super
      @name = "Snowflake"
      @driver = File.exist?(@@dylib)
      @snowsql = File.executable?(@@binary)
    end

    satisfy(build_env: false) do
      @driver # Require the driver to build.
    end

    def message
      <<~EOS
        Sqitch Snowflake support requires the Snowflake ODBC driver.
        Installation: #{ download }
      EOS
    end

    def notes
      msg = "Snowflake support requires the Snowflake ODBC driver and SnowSQL\n\n" \
            "- Found ODBC driver #{ @@dylib }\n"
      if @snowsql
        msg += "- Found SnowSQL binary: #{ @@binary }\n" \
               "  Make sure it's in your \$PATH or tell Sqitch where to find it by running:\n\n" \
               "      sqitch config --user engine.snowflake.client #{ @@binary }\n"
      else
        msg += "- SnowSQL not found; installation instructions:\n" \
               "  https://docs.snowflake.net/manuals/user-guide/snowsql-install-config.html\n"
      end
      return msg
    end
  end

  homepage   'https://sqitch.org/'
  version    '0.9998'
  url        "http://cpan.cpantesters.org/authors/id/D/DW/DWHEELER/App-Sqitch-#{stable.version}.tar.gz"
  sha256     'a0e39514470256cd2953cd6c13e0429db9cb904bf1fe52c01238d35d2c2f4c6e'
  head       'https://github.com/sqitchers/sqitch.git', :branch => 'bundle' # XXX remove branch
  depends_on Perl510Req
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
    depends_on "openssl" => :build
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
    depends_on SnowflakeReq
  end

  def install
    # Download Module::Build and Menlo::CLI::Compat.
    cpanmArgs = %W[--local-lib instutil --quiet --notest];
    system 'cpanm', *cpanmArgs, 'Menlo::CLI::Compat', 'Module::Build'
    ENV['PERL5LIB'] = "#{buildpath}/instutil/lib/perl5"

    if build.head?
      # Need to tell the compiler where to find OpenSSL and Gettext stuff.
      gettext = Formula["gettext"]
      openssl = Formula["openssl"]
      ENV.append "LDFLAGS",  "-L#{openssl.opt_lib} -L#{gettext.opt_lib}"
      ENV.append "CFLAGS",   "-I#{openssl.opt_include} -I#{gettext.opt_include}"
      ENV.append "CPPFLAGS", "-I#{openssl.opt_include} -I#{gettext.opt_include}"
      ENV.prepend_path "PATH", gettext.opt_bin

      # Download Dist::Zilla and plugins, then make and cd into a build dir.
      system 'cpanm', *cpanmArgs, 'Dist::Zilla'
      system './instutil/bin/dzil authordeps --missing | cpanm ' + cpanmArgs.join(' ')
      system './instutil/bin/dzil', 'build', '--in', '.brew'
      Dir.chdir '.brew'
    end

    # Pull together features.
    args = %W[Build.PL --quiet --install_base #{prefix} --etcdir #{etc}/sqitch]
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

  def post_install
    requirements.each do |req|
      if req.class.method_defined? :notes
        ohai "#{ req.name } Support Notes", req.notes, "\n"
      end
    end
  end
end
