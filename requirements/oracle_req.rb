require "requirement"

class OracleReq < Requirement
  @have_home = false
  @oracle_home = ""
  @dylib = ""
  @sdk = ""
  @sqlplus = ""
  @have_dylib = false
  @have_sdk = false
  @have_sqlplus = false
  fatal true
  download "http://www.oracle.com/technetwork/topics/intel-macsoft-096467.html"

  def initialize(tags = [])
    super
    @name = "Oracle"
    @have_home = ENV.include?("ORACLE_HOME")
    if @have_home
      @oracle_home  = ENV["ORACLE_HOME"]
      @dylib        = File.join(@oracle_home, "libclntsh.dylibb")
      @sdk          = File.join(@oracle_home, "sdk/include")
      @sqlplus      = File.join(@oracle_home, "sqlplus")
      @have_dylib   = File.exist? @dylib
      @have_sdk     = File.directory? @sdk
      @have_sqlplus = File.executable? @sqlplus
    end
  end

  satisfy(build_env: false) { @have_home && @have_dylib && @have_sdk }

  def message
    if @have_home
      msg = <<~EOS
        Sqitch Oracle support requires the Oracle Instant Client Basic,
        SQL*Plus, and SDK packages. The following are packages missing
        from ORACLE_HOME #{ @oracle_home }:
      EOS
      msg += "\n  - instantclient-basic"   if !@have_dylib
      msg += "\n  - instantclient-sdk"     if !@have_sdk
      msg += "\n  - instantclient-sqlplus" if !@have_sqlplus
      msg + "\n\nDownload from here:\n\n  #{ download }\n"
    else
      <<~EOS
      Sqitch Oracle support requires the Oracle Instant Client Basic, SQL*Plus,
      and SDK packages. Set \$ORACLE_HOME to point to their directory.
    EOS
    end
  end

  def notes
    msg = "Oracle support requires the Oracle Instant Client Basic, SQL*Plus,\n" \
          "and SDK packages.\n\n" \
          "- Found Basic:    #{ @dylib }\n" \
          "- Found SDK:      #{ @sdk }\n"
    if @have_sqlplus
      msg += "- Found SQL*Plus: #{ @sqlplus }\n\n" \
             "  Make sure SQL*Plus is in your \$PATH or tell Sqitch where to find\n" \
             "  it by running:\n\n" \
             "      sqitch config --user engine.oracle.client #{ @sqlplus }\n\n"
    else
      msg += "- SQL*Plus not found; download it from here:\n\n" \
             "    #{ download }\n\n"
             "  Once it's installed, make sure it's in your \$PATH or tell Sqitch\n" \
             "  where to find it by running:\n\n" \
             "      sqitch config --user engine.oracle.client /path/to/snowsl\n\n"
    end
    return msg
  end
end
