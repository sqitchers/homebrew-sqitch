require 'formula'

class SqitchMysql < Formula
  homepage   'https://sqitch.org/'
  version    '0'
  url        "file://#{HOMEBREW_REPOSITORY}/README.md", :using => :nounzip
  sha256     Pathname.new("#{HOMEBREW_REPOSITORY}/README.md").sha256

  def install
    odie <<~EOS
      The sqitch_mysql formula is no more. Use the --with-mysql-support
      option for the sqitch formula, instead:

          brew install sqitch --with-mysql-support

      Consult the Sqitch Tap README for additional information:

        https://github.com/sqitchers/homebrew-sqitch#readme

    EOS
  end

end
