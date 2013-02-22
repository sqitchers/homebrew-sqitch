require 'formula'
require 'vendor/multi_json'

class SqitchDependencies < Formula
  version    '0.952'
  url        "http://api.metacpan.org/source/DWHEELER/App-Sqitch-#{stable.version}/META.json", :using => :nounzip
  sha1       '6067e3789ae7487ff34d0dd35538d07c921d6f12'
  homepage   'http://sqitch.org/'
  depends_on 'cpanminus'

  def install
    arch  = %x(perl -MConfig -E 'print $Config{archname}')
    plib  = "#{HOMEBREW_PREFIX}/lib/perl5"
    perl  = "perl -I '#{plib}' -I '#{plib}/#{arch}'"
    cpanm = "#{perl} #{HOMEBREW_PREFIX}/bin/cpanm"

    open url do |f|
      MultiJson.decode(f.read)['prereqs'].each do |mode, prereqs|
        prereqs.each do |time, list|
          list.each do |pkg, version|
            system "#{cpanm} --local-lib '#{prefix}' --notest #{pkg}"
          end
        end
      end
    end

    # Remove perllocal.pod, since it just gets in the way of other modules.
    rm "#{prefix}/lib/perl5/#{arch}/perllocal.pod"
  end
end
