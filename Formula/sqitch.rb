require 'formula'
require_relative '../requirements/snowflake_req'
require_relative '../requirements/firebird_req'
require_relative '../requirements/oracle_req'
require_relative '../requirements/vertica_req'
require_relative '../requirements/exasol_req'

class Sqitch < Formula
  homepage   'https://sqitch.org/'
  version    'v1.1.0'
  url        "https://www.cpan.org/authors/id/D/DW/DWHEELER/App-Sqitch-#{stable.version}.tar.gz"
  sha256     'ee146cd75d6300837e6ca559bb0bde247d42123c96b2c5d4b2800f38d3e3d1ab'
  head       'https://github.com/sqitchers/sqitch.git'
  depends_on 'perl'
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
    depends_on VerticaReq
  end

  if build.with? "exasol-support"
    depends_on "libiodbc" => :recommended
    depends_on ExasolReq
  end

  if build.with? "snowflake-support"
    depends_on "libiodbc" => :recommended
    depends_on SnowflakeReq
  end

  def install
    # Download Module::Build and Menlo::CLI::Compat.
    cpanmArgs = %W[--local-lib instutil --notest];
    cpanmArgs.push("--verbose") if verbose?
    cpanmArgs.push("--quiet") if quiet?
    system 'cpanm', *cpanmArgs, 'Menlo::CLI::Compat', 'Module::Build'

    ENV['PERL5LIB'] = "#{buildpath}/instutil/lib/perl5"
    ENV['PERL_MM_OPT'] = 'INSTALLDIRS=vendor'
    ENV['PERL_MB_OPT'] = '--installdirs vendor'

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
    args = %W[Build.PL --install_base #{prefix} --etcdir #{etc}/sqitch]
    args.push("--verbose") if verbose?
    args.push("--quiet") if quiet?
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
    # Show notes from requirements.
    requirements.each do |req|
      if req.respond_to? :notes
        ohai "#{ req.name } Support Notes", req.notes
      end
    end
  end
end
