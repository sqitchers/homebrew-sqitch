require 'formula'
require 'vendor/multi_json'

class SqitchDependencies < Formula
  version    '0.952'
  url        "http://api.metacpan.org/source/DWHEELER/App-Sqitch-#{stable.version}/META.json", :using => :nounzip
  sha1       '6067e3789ae7487ff34d0dd35538d07c921d6f12'
  homepage   'http://sqitch.org/'
  depends_on 'cpanminus'

  def install
    open url do |f|
      MultiJson.decode(f.read)['prereqs'].each do |mode, prereqs|
        prereqs.each do |time, list|
          list.each do |pkg, version|
            system "cpanm --local-lib-contained '#{prefix}' --notest '#{pkg}'"
          end
        end
      end
    end
    
  end
end
