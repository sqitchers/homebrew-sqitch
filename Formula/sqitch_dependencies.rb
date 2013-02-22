require 'formula'
require 'vendor/multi_json'

class SqitchDependencies < Formula
  version    '0.952'
  url        "http://api.metacpan.org/source/DWHEELER/App-Sqitch-#{stable.version}/META.json", :using => :nounzip
  sha1       '6067e3789ae7487ff34d0dd35538d07c921d6f12'
  homepage   'http://sqitch.org/'
  depends_on 'cpanminus'
  head       "http://api.metacpan.org/source/DWHEELER/App-Sqitch-#{stable.version}/META.json", :using => :nounzip

  def install
    open url do |f|
      MultiJson.decode(f.read)['prereqs'].each do |mode, prereqs|
        next if mode == 'test' && !(build.head? || build.devel?)
        prereqs.each do |time, list|
          list.each do |pkg, version|
            system "cpanm --local-lib-contained '#{prefix}' --notest #{pkg}"
          end
        end
      end
    end

    if build.head? || build.devel?
      # Also need Dist::Zilla and a bunch of plugins.
      system "cpanm --local-lib-contained '#{prefix}' --notest Dist::Zilla"
      %w{AutoPrereqs CheckExtraTests ConfirmRelease ExecDir GatherDir License LocaleTextDomain Manifest ManifestSkip MetaJSON MetaNoIndex MetaResources MetaYAML ModuleBuild Prereqs PruneCruft Readme ShareDir TestRelease UploadToCPAN VersionFromModule}.each do |plugin|
        system "cpanm --local-lib-contained '#{prefix}' --notest Dist::Zilla::Plugin::#{plugin}"
      end
    end

    # Remove perllocal.pod, simce it just gets in the way of other modules.
    arch = %x(perl -MConfig -E 'print $Config{archname}')
    rm "#{prefix}/lib/perl5/#{arch}/perllocal.pod"
  end
end
