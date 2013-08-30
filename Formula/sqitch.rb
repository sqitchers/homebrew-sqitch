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

  homepage   'http://sqitch.org/'
  version    '0.980'
  url        "http://cpan.cpantesters.org/authors/id/D/DW/DWHEELER/App-Sqitch-#{stable.version}.tar.gz"
  sha1       'ae6e1ae390131e6d9e91da0cb4f094b289bdd6d4'
  head       'https://github.com/theory/sqitch.git'
  depends_on Perl510
  depends_on 'sqitch_dependencies'

  if build.head? || build.devel?
    depends_on 'sqitch_maint_depends'
    depends_on 'gettext'
  end

  def install
    arch  = %x(perl -MConfig -E 'print $Config{archname}')
    plib  = "#{HOMEBREW_PREFIX}/lib/perl5"
    ENV['PERL5LIB'] = "#{plib}:#{plib}/#{arch}:#{lib}:#{lib}/#{arch}"
    ENV.remove_from_cflags(/-march=\w+/)
    ENV.remove_from_cflags(/-msse\d?/)

    if build.head? || build.devel?
      # Install any missing dependencies.
      %w{authordeps listdeps}.each do |cmd|
        system "dzil #{cmd} | cpanm --local-lib '#{prefix}'"
      end

      # Build it in sqitch-HEAD and then cd into it.
      system "dzil build --in sqitch-HEAD"
      Dir.chdir 'sqitch-HEAD'

      # Remove perllocal.pod, simce it just gets in the way of other modules.
      rm "#{prefix}/lib/perl5/#{arch}/perllocal.pod", :force => true
    end

    system "perl Build.PL --install_base '#{prefix}' --installed_etcdir '#{HOMEBREW_PREFIX}/etc/sqitch'"
    system "./Build"

    # Add the Homebrew Perl lib dirs to sqitch.
    inreplace 'blib/script/sqitch' do |s|
      s.sub! /use /, "use lib '#{plib}', '#{plib}/#{arch}';\nuse "
      if `perl -E 'print $]'`.to_f == 5.01000
        s.sub!(/ -CAS/, '')
      end
    end

    system "./Build install"
  end
end
