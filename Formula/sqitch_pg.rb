require 'formula'

class SqitchPg < Formula
  homepage   'https://sqitch.org/'
  version    '0'
  url        "file://#{HOMEBREW_REPOSITORY}/README.md", :using => :nounzip
  sha256     Pathname.new("#{HOMEBREW_REPOSITORY}/README.md").sha256

  def install
    odie <<~EOS
      The sqitch_pg formula is no more. Use the --with-postgres-support
      option for the sqitch formula, instead:

          brew install sqitch --with-postgres-support

      Consult the Sqitch Tap README for additional information:

        https://github.com/sqitchers/homebrew-sqitch#readme

    EOS
  end

end
