require "requirement"

class SnowflakeReq < Requirement
  @@dylib = "/opt/snowflake/snowflakeodbc/lib/universal/libSnowflake.dylib"
  @@binary = "/Applications/SnowSQL.app/Contents/MacOS/snowsql"
  @snowsql = false
  @driver = false
  fatal true
  download "https://docs.snowflake.net/manuals/user-guide/odbc-mac.html"

  def initialize(tags = [])
    super
    @name = "Snowflake"
    @driver = File.exist?(@@dylib)
    @snowsql = File.executable?(@@binary)
   end

  satisfy(build_env: false) { @driver }

  def message
    <<~EOS
      Sqitch Snowflake support requires the Snowflake ODBC driver.
      Installation: #{ download }
    EOS
  end

  def notes
    msg = "Snowflake support requires the Snowflake ODBC driver and SnowSQL\n\n" \
          "- Found ODBC driver #{ @@dylib }\n"
    if @snowsql
      msg += "- Found SnowSQL binary: #{ @@binary }\n" \
             "  Make sure it's in your \$PATH or tell Sqitch where to find it by running:\n\n" \
             "      sqitch config --user engine.snowflake.client #{ @@binary }\n"
    else
      msg += "- SnowSQL not found; installation instructions:\n" \
             "  https://docs.snowflake.net/manuals/user-guide/snowsql-install-config.html\n"
    end
    return msg
  end
end
