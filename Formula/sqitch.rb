require_relative "../requirements/snowflake_req"
require_relative "../requirements/firebird_req"
require_relative "../requirements/oracle_req"
require_relative "../requirements/vertica_req"
require_relative "../requirements/exasol_req"

class Sqitch < Formula
  desc       "Sensible database change management"
  homepage   "https://sqitch.org/"
  url        "https://www.cpan.org/authors/id/D/DW/DWHEELER/App-Sqitch-v1.4.0.tar.gz"
  sha256     "b0db387031f77562662e003bc55d7a102a26380b4ad7fdb9a8a3bad5769e501c"
  license    "MIT"
  head       "https://github.com/sqitchers/sqitch.git", branch: "develop"

  option "with-postgres-support",  "Support for managing PostgreSQL-compatible databases"
  option "with-sqlite-support",    "Support for managing SQLite databases"
  option "with-mysql-support",     "Support for managing MySQL databases"
  option "with-firebird-support",  "Support for managing Firbird databases"
  option "with-oracle-support",    "Support for managing Oracle databases"
  option "with-vertica-support",   "Support for managing Vertica databases"
  option "with-exasol-support",    "Support for managing Exasol databases"
  option "with-snowflake-support", "Support for managing Snowflake databases"
  option "with-std-env",           "Build against custom non-Homebrew dependencies"

  depends_on "cpm" => :build
  depends_on FirebirdReq    if build.with? "firebird-support"
  depends_on "libpq"        if build.with? "postgres-support"
  depends_on "mysql-client" if build.with? "mysql-support"
  depends_on OracleReq      if build.with? "oracle-support"
  depends_on "perl"
  depends_on "sqlite"       if build.with? "sqlite-support"

  env :std if build.with? "std-env"

  if build.head?
    depends_on "gettext" => :build
    depends_on "openssl@3" => :build
  end

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
    cpan_args = %w[install --local-lib-contained instutil --no-test]
    cpan_args.push("--verbose") if verbose?
    # cpan_args.push("--quiet") if quiet?
    system "cpm", *cpan_args, "Menlo::CLI::Compat", "Module::Build"

    ENV["PERL5LIB"] = "#{buildpath}/instutil/lib/perl5"
    ENV["PERL_MM_OPT"] = "INSTALLDIRS=vendor"
    ENV["PERL_MB_OPT"] = "--installdirs vendor"

    if build.head?
      # Need to tell the compiler where to find Gettext.
      ENV.prepend_path "PATH", Formula["gettext"].opt_bin

      # Download Dist::Zilla and plugins, then make and cd into a build dir.
      system "cpm", *cpan_args, "Dist::Zilla"
      system "./instutil/bin/dzil authordeps --missing | xargs cpm " + cpan_args.join(" ")
      system "./instutil/bin/dzil", "build", "--in", ".brew"
      Dir.chdir ".brew"
    end

    # Pull together features.
    args = %W[Build.PL --install_base #{prefix} --etcdir #{etc}/sqitch]
    args.push("--verbose") if verbose?
    args.push("--quiet") if quiet?
    %w[postgres sqlite mysql firebird oracle vertica exasol snowflake].each do |f|
      args.push("--with", f) if build.with? "#{f}-support"
    end

    # Build and bundle (install).
    # XXX Fix for wayward Data::Dump in v1.4.0.
    system "perl -i -pe 's/(use Data::Dump.+)//' inc/Menlo/Sqitch.pm"
    system "perl", *args
    system "./Build", "bundle"

    # Wrap the binary in client paths if necessary.
    # https://github.com/orgs/Homebrew/discussions/4391
    if build.with?("postgres-support") || build.with?("mysql-support")
      paths = []
      paths.push(Formula["libpq"].opt_bin) if build.with? "postgres-support"
      paths.push(Formula["mysql-client"].opt_bin) if build.with? "mysql-support"

      mkdir_p libexec
      mv bin/"sqitch", libexec/"sqitch"
      (bin/"sqitch").write_env_script libexec/"sqitch", PATH: "#{paths.join(":")}:$PATH"
    end

    # Move the man pages from #{prefix}/man to man.
    mkdir share
    mv "#{prefix}/man", man
  end

  def post_install
    # Show notes from requirements.
    requirements.each do |req|
      ohai "#{req.name} Support Notes", req.notes if req.respond_to? :notes
    end
  end

  test do
    system bin/"sqitch", "--version"
  end
end
