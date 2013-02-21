require 'formula'

class Sqitch < Formula
  homepage   'http://sqitch.org/'
  version    '0.952'
  url        'http://cpan.metacpan.org/authors/id/D/DW/DWHEELER/App-Sqitch-#{version}.tar.gz'
  sha1       '478aeffa99499aed363f83c611360f6e56d1e1d5'
  head       'https://github.com/theory/sqitch.git'
  depends_on 'sqitch_dependencies'

  def install
    system "perl Build.PL"
    system "./Build"
    system "./Build install"
  end

end
