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
  url        "https://cpan.metacpan.org/authors/id/D/DW/DWHEELER/App-Sqitch-#{stable.version}.tar.gz"
  sha256     '7588b4b6dc3d68fc732b8db74f18ec4ff1d8ec84939b2fa596cb1e57cb7474d0'
  head       'https://github.com/sqitchers/sqitch.git'
  depends_on Perl510
  depends_on 'cpanminus' => :build

  option 'with-pg',        "Support for managing PostgreSQL databases"
  option 'with-sqlite',    "Support for managing SQLite databases"
  option 'with-mysql',     "Support for managing MySQL databases"
  option 'with-firebird',  "Support for managing Firbird databases"
  option 'with-oracle',    "Support for managing Oracle databases"
  option 'with-vertica',   "Support for managing Vertica databases"
  option 'with-exasol',    "Support for managing Exasol databases"
  option 'with-snowflake', "Support for managing Snowflake databases"

  if build.head?
    depends_on 'gettext' => :build
  end

  if build.with? "pg"
    depends_on 'postgresql' => :recommended
  end

  if build.with? "sqlite"
    depends_on 'sqlite' => :recommended
  end

  if build.with? "mysql"
    depends_on 'mysql' => :recommended
  end

  if build.with? "firebird"
    ohai "Firebird support requires the Firebird database and isql"
    ohai "  - Downloads: https://www.firebirdsql.org/en/server-packages/"
    ohai "  - isql Docs: https://firebirdsql.org/manual/isql.html"
  end

  if build.with? "oracle"
    depends_on "libiodbc" => :recommended
    ohai "Oracle support requires the Oracle Instant Client ODBC and SQL*Plus packages"
    ohai "  - Instant Client: http://www.oracle.com/technetwork/topics/intel-macsoft-096467.html"
    ohai "  - ODBC Docs: https://blogs.oracle.com/opal/installing-the-oracle-odbc-driver-on-macos"
  end

  if build.with? "vertica"
    depends_on "libiodbc" => :recommended
    ohai "Vertica support requires the Vertica ODBC driver and vsql"
    ohai "  - Downloads: https://my.vertica.com/download/vertica/client-drivers/"
    ohai "  - ODBC Docs: https://my.vertica.com/docs/9.1.x/HTML/index.htm#Authoring/ConnectingToVertica/InstallingDrivers/MacOSX/InstallingTheODBCDriverOnMacOSX.htm"
  end

  if build.with? "exasol"
    depends_on "libiodbc" => :recommended
    ohai "Exasol support requires the Exasol ODBC driver and exaplus"
    ohai "  - Downloads: https://www.exasol.com/portal/display/DOWNLOAD/"
    ohai "  - Docs: https://www.exasol.com/portal/pages/viewpage.action?pageId=4030482"
  end

  if build.with? "snowflake"
    depends_on "libiodbc" => :recommended
    ohai "Snowflake support requires the Snowflake ODBC driver and SnowSQL"
    ohai "  - ODBC Driver: https://docs.snowflake.net/manuals/user-guide/odbc-mac.html"
    okay "  - SnowSQL: https://docs.snowflake.net/manuals/user-guide/snowsql.html"
  end

  def install
    if build.head?
      # XXX Install Dist::Zilla and plugins and generate a build.
    end

    # XXX Download Menlo::CLI::Compat.

    # Pull together features.
    args = []
    %w{pg sqlite mysql firebird oracle vertica exasol snowflake}.each { |f|
      args << "--with #{f}" if build.with? f
    }

    # Build and bundle (install).
    system "perl", *%W[Build.PL --install_base #{prefix} --etcdir #{etc}]
    system "./Build", "bundle", *args

    # Move the man pages from #{prefix}/man to #{prefix}/share/man.
    mkdir "#{prefix}/share"
    mv "#{prefix}/man", "#{prefix}/share/man"
  end
end


    # arch  = %x(perl -MConfig -E 'print $Config{archname}')
    # plib  = "#{HOMEBREW_PREFIX}/lib/perl5"
    # ENV['PERL5LIB'] = "#{plib}:#{plib}/#{arch}:#{lib}:#{lib}/#{arch}"
    # ENV.remove_from_cflags(/-march=\w+/)
    # ENV.remove_from_cflags(/-msse\d?/)

    # if build.head? || build.devel?
    #   # Install any missing dependencies.
    #   %w{authordeps listdeps}.each do |cmd|
    #     system "dzil #{cmd} | cpanm --local-lib '#{prefix}'"
    #   end

    #   # Build it in sqitch-HEAD and then cd into it.
    #   system "dzil build --in sqitch-HEAD"
    #   Dir.chdir 'sqitch-HEAD'

    #   # Remove perllocal.pod, simce it just gets in the way of other modules.
    #   rm "#{prefix}/lib/perl5/#{arch}/perllocal.pod", :force => true
    # end

    # system "perl Build.PL --install_base '#{prefix}' --installed_etcdir '#{HOMEBREW_PREFIX}/etc/sqitch'"
    # system "./Build"

    # # Add the Homebrew Perl lib dirs to sqitch.
    # inreplace 'blib/script/sqitch' do |s|
    #   s.sub! /use /, "use lib '#{plib}', '#{plib}/#{arch}';\nuse "
    #   if `perl -E 'print $]'`.to_f == 5.01000
    #     s.sub!(/ -CAS/, '')
    #   end
    # end

    # system "./Build install"
