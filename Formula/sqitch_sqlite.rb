class SqitchSqlite < Formula
  desc       "Replaced by `brew install sqitch --with-sqlite-support`"
  homepage   "https://sqitch.org/"
  url        "file://#{HOMEBREW_REPOSITORY}/README.md", using: :nounzip
  version    "0"
  sha256     Pathname.new("#{HOMEBREW_REPOSITORY}/README.md").sha256

  def install
    odie <<~EOS
      The sqitch_sqlite formula is no more. Use the --with-sqlite-support
      option for the sqitch formula, instead:

          brew install sqitch --with-sqlite-support

      Consult the Sqitch Tap README for additional information:

        https://github.com/sqitchers/homebrew-sqitch#readme

    EOS
  end
end
