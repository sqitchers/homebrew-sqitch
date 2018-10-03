require 'formula'

class SqitchVertica < Formula
  homepage   'https://sqitch.org/'
  version    '0'
  url        "file://#{HOMEBREW_REPOSITORY}/README.md", :using => :nounzip
  sha256     Pathname.new("#{HOMEBREW_REPOSITORY}/README.md").sha256

  def install
    odie <<~EOS
      The sqitch_vertica formula is no more. Use the --with-vertica-support
      option for the sqitch formula, instead:

          brew install sqitch --with-vertica-support

      Consult the Sqitch Tap README for additional information:

        https://github.com/sqitchers/homebrew-sqitch#readme

    EOS
  end

end
