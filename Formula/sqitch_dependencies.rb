require 'formula'
require 'vendor/multi_json'

class SqitchDependencies < Formula
  version    '0.953'
  url        "http://api.metacpan.org/source/DWHEELER/App-Sqitch-#{stable.version}/META.json", :using => :nounzip
  sha1       '562f8ba594461d9fd22de530c9288807e3f2cfdd'
  homepage   'http://sqitch.org/'
  depends_on 'cpanminus'

  def install
    arch  = %x(perl -MConfig -E 'print $Config{archname}')
    plib  = "#{HOMEBREW_PREFIX}/lib/perl5"
    ENV['PERL5LIB'] = "#{plib}:#{plib}/#{arch}"

    open url do |f|
      MultiJson.decode(f.read)['prereqs'].each do |mode, prereqs|
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
