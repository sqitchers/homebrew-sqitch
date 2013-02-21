require 'formula'

class Sqitch < Formula
  homepage   'http://sqitch.org/'
  version    '0.952'
  url        'http://cpan.metacpan.org/authors/id/D/DW/DWHEELER/App-Sqitch-#{version}.tar.gz'
  sha1       '478aeffa99499aed363f83c611360f6e56d1e1d5'
  head       'https://github.com/theory/sqitch.git'
  depends_on 'sqitch_dependencies'

  def install
    arch = %x(perl -MConfig -E 'print $Config{archname}')
    plib = "#{HOMEBREW_PREFIX}/lib/perl5"
    system "perl -I '#{plib}' -I '#{plib}/#{arch}' Build.PL --install_base '#{prefix}'"
    system "./Build"
    # Add the Homebrew Perl lib dirs to sqitch.
    inreplace 'blib/script/sqitch' do |s|
      s.sub! /use /, "use lib '#{plib}', '#{plib}/#{arch}';\nuse "
      puts "S: #{s}"
    end
    system "./Build install"
  end

end
