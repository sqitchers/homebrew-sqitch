require 'formula'

class Sqitch < Formula
  homepage   'http://sqitch.org/'
  version    '0.953'
  url        "http://cpan.cpantesters.org/authors/id/D/DW/DWHEELER/App-Sqitch-#{stable.version}.tar.gz"
  sha1       '0e9a90597a3c3240ed1aa00d7888d1f9445984e0'
  head       'https://github.com/theory/sqitch.git'
  depends_on 'sqitch_dependencies'
  depends_on 'gettext' if build.head? || build.devel?

  def install
    arch = %x(perl -MConfig -E 'print $Config{archname}')
    plib = "#{HOMEBREW_PREFIX}/lib/perl5"
    perl = "perl -I '#{plib}' -I '#{plib}/#{arch}'"

    if build.head? || build.devel?
      # We need to install other depenencies.
      dzil  = "#{perl} #{HOMEBREW_PREFIX}/bin/dzil"
      cpanm = "#{perl} #{HOMEBREW_PREFIX}/bin/cpanm"

      # Install any missing author dependencies.
      IO.popen("#{dzil} authordeps").each do |l|
        system "#{cpanm} --local-lib '#{prefix}' --notest #{l.chomp}"
      end

      # Install any other missing dependencies.
      IO.popen("#{dzil} listdeps").each do |l|
        system "#{cpanm} --local-lib '#{prefix}' --notest #{l.chomp}"
      end

      # Build it in sqitch-HEAD and then cd into it.
      system "#{dzil} build --in sqitch-HEAD"
      Dir.chdir 'sqitch-HEAD'
    end

    system "#{perl} Build.PL --install_base '#{prefix}' --installed_etcdir '#{HOMEBREW_PREFIX}/etc/sqitch'"
    system "./Build"

    # Add the Homebrew Perl lib dirs to sqitch.
    inreplace 'blib/script/sqitch' do |s|
      s.sub! /use /, "use lib '#{plib}', '#{plib}/#{arch}';\nuse "
    end

    system "./Build install"

    # Remove perllocal.pod, simce it just gets in the way of other modules.
    arch = %x(perl -MConfig -E 'print $Config{archname}')
    rm "#{prefix}/lib/perl5/#{arch}/perllocal.pod"
  end
end
