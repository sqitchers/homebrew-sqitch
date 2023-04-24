class SqitchFirebird < Formula
  desc       "Replaced by `brew install sqitch --with-firebird-support`"
  homepage   "https://sqitch.org/"
  url        "file://#{HOMEBREW_REPOSITORY}/README.md", using: :nounzip
  version    "0"
  sha256     Pathname.new("#{HOMEBREW_REPOSITORY}/README.md").sha256

  def install
    odie <<~EOS
      The sqitch_firebird formula is no more. Use the --with-firebird-support
      option for the sqitch formula, instead:

          brew install sqitch --with-firebird-support

      Consult the Sqitch Tap README for additional information:

        https://github.com/sqitchers/homebrew-sqitch#readme

    EOS
  end
end
