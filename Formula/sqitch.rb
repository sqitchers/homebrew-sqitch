require "formula"

class Sqitch < Formula
  homepage   'https://sqitch.org/'

  opoo "Sqitch has switched the default branch from 'master' to 'main'"
  opoo "requiring an update to the default homebrew tap."
  opoo ""

  opoo """To upgrade sqitch, retap it with:
    brew untap sqitchers/sqitch
    brew tap sqitchers/sqitch
    brew upgrade sqitch"""
end
