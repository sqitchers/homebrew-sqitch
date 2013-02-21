require 'formula'
require 'vendor/multi_json'

class Sqitch < Formula
  homepage 'http://sqitch.org/'
  url 'http://cpan.metacpan.org/authors/id/D/DW/DWHEELER/App-Sqitch-0.952.tar.gz'
  sha1 '478aeffa99499aed363f83c611360f6e56d1e1d5'
  head 'https://github.com/theory/sqitch.git'
  depends_on 'cpanminus'

  def install
    open 'META.json' do |f|
      MultiJson.decode(f.read)['prereqs'].each do |mode, prereqs|
        prereqs.each do |time, list|
          list.each do |pkg, version|
            puts "#{pkg} #{version}"
          end
        end
      end
    end
    return 1;

    # system "perl Build.PL"
    # system "./Build"
    # system "./Build install"
  end
end
