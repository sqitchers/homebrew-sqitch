class FirebirdReq < Requirement
  @@framework = "/Library/Frameworks/Firebird.framework"
  @@isql = "/Library/Frameworks/Firebird.framework/Resources/bin/isql"
  @have_isql = false
  @have_framework = false
  fatal true
  download "https://www.firebirdsql.org/en/server-packages/"

  def initialize(tags = [])
    super
    @name = "Firebird"
    @have_framework = File.directory?(@@framework)
    @have_isql = File.executable?(@@isql)
   end

  satisfy(build_env: false) { @have_framework }

  def message
    <<~EOS
      Sqitch Firebird support requires the Firebird Server Package.
      Download from: #{download}
    EOS
  end

  def notes
    msg = "Firebird support requires the Firebird Server Framework\n\n" \
          "- Found Framework #{@@framework}\n"
    if @have_isql
      msg += "- Found isql binary: #{@@isql}\n" \
             "  Make sure it's in your \$PATH or tell Sqitch where to find it by running:\n\n" \
             "      sqitch config --user engine.firebird.client #{@@isql}\n\n"
    else
      msg += "- Cannot find isql binary in framework; installation instructions:\n\n" \
             "    https://www.firebirdsql.org/file/documentation/reference_manuals/user_manuals/html/qsg3-installing.html\n\n" \
             "  Once it's installed, make sure it's in your \$PATH or tell Sqitch\n" \
             "  where to find it by running:\n\n" \
             "      sqitch config --user engine.firebird.client /path/to/isql\n\n"
    end
    return msg
  end
end
