require 'formula'
require_relative '../requirements/perl510_req'
require_relative '../requirements/snowflake_req'
require_relative '../requirements/firebird_req'
require_relative '../requirements/oracle_req'

class Sqitch < Formula
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
    depends_on FirebirdReq
  end

  if build.with? "oracle-support"
    depends_on OracleReq
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

    if build.with? "oracle-support"
      # Set ORACLE_HOME && DYLD_LIBRARY_PATH.
      ENV.prepend_path "DYLD_LIBRARY_PATH", ENV["ORACLE_HOME"]
    end

    # Build and bundle (install).
    system "perl", *args
    system "./Build", "bundle"

    # Move the man pages from #{prefix}/man to #{prefix}/share/man.
    mkdir "#{prefix}/share"
    mv "#{prefix}/man", "#{prefix}/share/man"
  end

  def post_install
    # Show notes from requirements.
    requirements.each do |req|
      if req.respond_to? :notes
        ohai "#{ req.name } Support Notes", req.notes
      end
    end
  end
end
