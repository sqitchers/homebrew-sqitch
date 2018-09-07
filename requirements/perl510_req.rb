require "requirement"

class Perl510Req < Requirement
  fatal true

  satisfy(build_env: false) { `perl -E 'print $]'`.to_f >= 5.01000 }

  def message
    "Sqitch requires Perl 5.10.0 or greater."
  end
end
