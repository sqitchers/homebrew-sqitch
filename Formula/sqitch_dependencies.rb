require 'formula'
require 'vendor/multi_json'

class SqitchDependencies < Formula
  version    '0.965'
  url        "http://api.metacpan.org/source/DWHEELER/App-Sqitch-#{stable.version}/META.json", :using => :nounzip
  sha1       'fc1c89aba0b0ef19db32a96a2da8155e54f62ebb'
  homepage   'http://sqitch.org/'
  depends_on 'cpanminus'

  def install
    arch  = %x(perl -MConfig -E 'print $Config{archname}')
    plib  = "#{HOMEBREW_PREFIX}/lib/perl5"
    ENV['PERL5LIB'] = "#{plib}:#{plib}/#{arch}:#{lib}:#{lib}/#{arch}"
    ENV.remove_from_cflags(/-march=\w+/)
    ENV.remove_from_cflags(/-msse\d?/)

    open 'META.json' do |f|
      MultiJson.decode(f.read)['prereqs'].each do |mode, prereqs|
       next if mode == 'test'
        prereqs.each do |time, list|
          list.each do |pkg, version|
            system "cpanm --local-lib '#{prefix}' --notest #{pkg}"
          end
        end
      end
    end

    # Remove perllocal.pod, since it just gets in the way of other modules.
    rm "#{prefix}/lib/perl5/#{arch}/perllocal.pod", :force => true
  end
end
