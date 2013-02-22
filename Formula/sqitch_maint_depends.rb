require 'formula'
require 'vendor/multi_json'

class SqitchMaintDepends < Formula
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

    # Install all the testing dependencies
    open url do |f|
      MultiJson.decode(f.read)['prereqs']['test'].each do |time, list|
        list.each do |pkg, version|
          system "#{cpanm} --local-lib '#{prefix}' --notest #{pkg}"
        end
      end
    end

    # Also need Dist::Zilla and a bunch of plugins.
    system "#{cpanm} --local-lib '#{prefix}' --notest Dist::Zilla"
    %w{AutoPrereqs CheckExtraTests ConfirmRelease ExecDir GatherDir License LocaleTextDomain Manifest ManifestSkip MetaJSON MetaNoIndex MetaResources MetaYAML ModuleBuild Prereqs PruneCruft Readme ShareDir TestRelease UploadToCPAN VersionFromModule}.each do |plugin|
      system "#{cpanm} --local-lib '#{prefix}' --notest Dist::Zilla::Plugin::#{plugin}"
    end

    # Remove perllocal.pod, since it just gets in the way of other modules.
    rm "#{prefix}/lib/perl5/#{arch}/perllocal.pod"
  end
end
