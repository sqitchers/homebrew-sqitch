require 'formula'
require_relative '../requirements/snowflake_req'
require_relative '../requirements/firebird_req'
require_relative '../requirements/oracle_req'
require_relative '../requirements/vertica_req'
require_relative '../requirements/exasol_req'

class Sqitch < Formula
  homepage   'https://sqitch.org/'
  version    'v1.3.1'
  url        "https://www.cpan.org/authors/id/D/DW/DWHEELER/App-Sqitch-#{stable.version}.tar.gz"
  sha256     'f5e768d298cd4047ee2ae42319782e8c2cda312737bcbdbfaf580bd47efe8b94'
  head       'https://github.com/sqitchers/sqitch.git', branch: 'main'
  depends_on 'perl'
  depends_on 'cpm' => :build

  option 'with-postgres-support',  "Support for managing PostgreSQL-compatible databases"
  option 'with-sqlite-support',    "Support for managing SQLite databases"
  option 'with-mysql-support',     "Support for managing MySQL databases"
  option 'with-firebird-support',  "Support for managing Firbird databases"
  option 'with-oracle-support',    "Support for managing Oracle databases"
  option 'with-vertica-support',   "Support for managing Vertica databases"
  option 'with-exasol-support',    "Support for managing Exasol databases"
  option 'with-snowflake-support', "Support for managing Snowflake databases"
  option 'with-std-env',           "Build against custom non-Homebrew dependencies"

  if build.with? "std-env"
    env :std
  end

  if build.head?
    depends_on 'gettext' => :build
    depends_on "openssl@3" => :build
  end

  depends_on 'libpq'        if build.with? "postgres-support"
  depends_on 'sqlite'       if build.with? "sqlite-support"
  depends_on 'mysql-client' if build.with? "mysql-support"
  depends_on FirebirdReq    if build.with? "firebird-support"
  depends_on OracleReq      if build.with? "oracle-support"

  if build.with? "vertica-support"
    depends_on "libiodbc"
    depends_on VerticaReq
  end

  if build.with? "exasol-support"
    depends_on "libiodbc"
    depends_on ExasolReq
  end

  if build.with? "snowflake-support"
    depends_on "libiodbc"
    depends_on SnowflakeReq
  end

  def install
    # Download Module::Build and Menlo::CLI::Compat.
    cpmArgs = %W[install --local-lib-contained instutil --no-test];
    cpmArgs.push("--verbose") if verbose?
    # cpmArgs.push("--quiet") if quiet?
    system 'cpm', *cpmArgs, 'Menlo::CLI::Compat', 'Module::Build'

    ENV['PERL5LIB'] = "#{buildpath}/instutil/lib/perl5"
    ENV['PERL_MM_OPT'] = 'INSTALLDIRS=vendor'
    ENV['PERL_MB_OPT'] = '--installdirs vendor'

    if build.head?
      # Need to tell the compiler where to find Gettext.
      ENV.prepend_path "PATH", Formula["gettext"].opt_bin

      # Download Dist::Zilla and plugins, then make and cd into a build dir.
      system 'cpm', *cpmArgs, 'Dist::Zilla'
      system './instutil/bin/dzil authordeps --missing | xargs cpm ' + cpmArgs.join(' ')
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

    # Wrap the binary in client paths if necessary.
    # https://github.com/orgs/Homebrew/discussions/4391
    if build.with?("postgres-support") || build.with?("mysql-support")
      paths = []
      if build.with? "postgres-support"
        paths.push(Formula["libpq"].opt_bin)
      end
      if build.with? "mysql-support"
        paths.push(Formula["mysql-client"].opt_bin)
      end

      mkdir_p libexec
      mv bin/"sqitch", libexec/"sqitch"
      (bin/"sqitch").write_env_script libexec/"sqitch", PATH: "#{paths.join(":")}:$PATH"
    end

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
