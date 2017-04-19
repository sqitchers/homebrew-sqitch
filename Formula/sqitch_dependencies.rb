require 'formula'

class SqitchDependencies < Formula
  version    '0.9995'
  url        "http://api.metacpan.org/source/DWHEELER/App-Sqitch-#{stable.version}/META.json", :using => :nounzip
  sha256     '167857eb22f7893a02ac3886dfac67e30aa8b83e03a67bb217810de2abebe02e'
  homepage   'http://sqitch.org/'
  depends_on 'cpanminus'
  conflicts_with 'sqitch_maint_depends',
    :because => "sqitch_dependencies and sqitch_maint_depends install the same plugins."

  def install
    arch  = %x(perl -MConfig -E 'print $Config{archname}')
    plib  = "#{HOMEBREW_PREFIX}/lib/perl5"
    ENV['PERL5LIB'] = "#{plib}:#{plib}/#{arch}:#{lib}:#{lib}/#{arch}"
    ENV.remove_from_cflags(/-march=\w+/)
    ENV.remove_from_cflags(/-msse\d?/)

    open 'META.json' do |f|
      Utils::JSON.parse(f.read)['prereqs'].each do |mode, prereqs|
        next if ['develop', 'test'].include? mode
        prereqs.each do |time, list|
          list.each do |pkg, version|
            next if pkg == 'perl'
            system "cpanm --local-lib '#{prefix}' --notest #{pkg}"
          end
        end
      end
    end

    # Remove perllocal.pod, since it just gets in the way of other modules.
    rm "#{prefix}/lib/perl5/#{arch}/perllocal.pod", :force => true
  end
end
