require 'formula'

class SqitchMysql < Formula
  homepage   'http://sqitch.org/'
  version    '0.982'
  depends_on 'sqitch'
  depends_on 'mysql'

  # Fool brew into not downloading anything by pointing it at its own README.
  url        "file://#{HOMEBREW_PREFIX}/README.md", :using => :nounzip
  sha1       Pathname.new("#{HOMEBREW_PREFIX}/README.md").sha1

  def install
    arch  = %x(perl -MConfig -E 'print $Config{archname}')
    plib  = "#{HOMEBREW_PREFIX}/lib/perl5"
    ENV['PERL5LIB'] = "#{plib}:#{plib}/#{arch}:#{lib}:#{lib}/#{arch}"
    ENV.remove_from_cflags(/-march=\w+/)
    ENV.remove_from_cflags(/-msse\d?/)

    system "cpanm --local-lib '#{prefix}' --notest DBD::mysql"

    # Remove perllocal.pod, since it just gets in the way of other modules.
    rm "#{prefix}/lib/perl5/#{arch}/perllocal.pod", :force => true
  end

end
