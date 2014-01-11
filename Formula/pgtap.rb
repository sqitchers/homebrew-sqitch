require 'formula'

class Pgtap < Formula
  homepage   'http://pgtap.org/'
  version    '0.94.0'
  url        "http://api.pgxn.org/dist/pgtap/#{stable.version}/pgtap-#{stable.version}.zip"
  sha1       '58c04a57d79345c18525ed4aee9db058964408a1'
  head       'https://github.com/theory/pgtap.git'
  depends_on Perl510
  depends_on 'postgresql'
  depends_on 'cpanminus'

  def install
    # Follow the PostgreSQL linked keg back to the active Postgres installation
    # as it is common for people to avoid upgrading Postgres.
    postgres_realpath = Formula.factory('postgresql').opt_prefix.realpath

    # Set up Perl build environment.
    arch  = %x(perl -MConfig -E 'print $Config{archname}')
    plib  = "#{HOMEBREW_PREFIX}/lib/perl5"
    ENV['PERL5LIB'] = "#{plib}:#{plib}/#{arch}:#{lib}:#{lib}/#{arch}"
    ENV.remove_from_cflags(/-march=\w+/)
    ENV.remove_from_cflags(/-msse\d?/)

    # Install TAP::Parser::SourceHandler::pgTAP.
    system "cpanm --local-lib '#{prefix}' --notest TAP::Parser::SourceHandler::pgTAP"

    # Remove perllocal.pod, since it just gets in the way of other modules.
    rm "#{prefix}/lib/perl5/#{arch}/perllocal.pod", :force => true

    # Now build and install pgTAP.
    system "make PGCONFIG=#{postgres_realpath}/bin/pg_config"
    system "make PGCONFIG=#{postgres_realpath}/bin/pg_config install"
  end
end
