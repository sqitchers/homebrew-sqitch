require 'formula'

class SqitchPg < Formula
  homepage   'http://sqitch.org/'
  version    '0.952'
  depends_on 'sqitch'
  depends_on 'postgresql'

  # Fool brew into not downloading anything by pointing it at its own README.
  url        "file://#{HOMEBREW_PREFIX}/README.md", :using => :nounzip
  sha1       Pathname.new("#{HOMEBREW_PREFIX}/README.md").sha1

  def install
    system "cpanm --local-lib '#{prefix}' --notest DBD::Pg"

    # Remove perllocal.pod, simce it just gets in the way of other modules.
    arch = %x(perl -MConfig -E 'print $Config{archname}')
    rm "#{prefix}/lib/perl5/#{arch}/perllocal.pod"
  end

end
