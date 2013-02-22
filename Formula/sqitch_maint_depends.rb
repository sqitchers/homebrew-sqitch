require 'formula'
require 'vendor/multi_json'

class SqitchMaintDepends < Formula
  version    '0.953'
  url        "http://api.metacpan.org/source/DWHEELER/App-Sqitch-#{stable.version}/META.json", :using => :nounzip
  sha1       '562f8ba594461d9fd22de530c9288807e3f2cfdd'
  homepage   'http://sqitch.org/'
  depends_on 'cpanminus'

  def install
    arch  = %x(perl -MConfig -E 'print $Config{archname}')
    plib  = "#{HOMEBREW_PREFIX}/lib/perl5"
    ENV['PERL5LIB'] = "#{plib}:#{plib}/#{arch}:#{lib}:#{lib}/#{arch}"

    # Install all the testing dependencies
    open url do |f|
      MultiJson.decode(f.read)['prereqs']['test'].each do |time, list|
        list.each do |pkg, version|
          system "cpanm --local-lib '#{prefix}' --notest #{pkg}"
        end
      end
    end

    # Also need Dist::Zilla and a bunch of plugins.
    system "cpanm --local-lib '#{prefix}' --notest Dist::Zilla"
    %w{AutoPrereqs CheckExtraTests ConfirmRelease ExecDir GatherDir License LocaleTextDomain Manifest ManifestSkip MetaJSON MetaNoIndex MetaResources MetaYAML ModuleBuild Prereqs PruneCruft Readme ShareDir TestRelease UploadToCPAN VersionFromModule}.each do |plugin|
      system "cpanm --local-lib '#{prefix}' --notest Dist::Zilla::Plugin::#{plugin}"
    end

    # Remove perllocal.pod, since it just gets in the way of other modules.
    rm "#{prefix}/lib/perl5/#{arch}/perllocal.pod", :force => true
  end
end
