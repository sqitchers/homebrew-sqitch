require "requirement"

class SnowflakeReq < Requirement
  @@dylib = "/opt/snowflake/snowflakeodbc/lib/universal/libSnowflake.dylib"
  @@client = "/Applications/SnowSQL.app/Contents/MacOS/snowsql"
  @have_client = false
  @have_dylib = false
  fatal false
  download "https://docs.snowflake.net/manuals/user-guide/odbc-mac.html"

  def initialize(tags = [])
    super
    @name = "Snowflake"
    @have_dylib = File.exist?(@@dylib)
    @have_client = File.executable?(@@client)
   end

  satisfy(build_env: false) { @have_dylib }

  def message
    <<~EOS
      Sqitch Snowflake support requires the Snowflake ODBC driver.
      Installation: #{ download }
    EOS
  end

  def notes
    msg = "Snowflake support requires the Snowflake ODBC driver and SnowSQL\n\n" \
    # Show found items.
    if @have_dylib
      msg +=  "- Found ODBC Driver #{ @@dylib }\n"
    end
    if @have_client
      msg += "- Found SnowSQL binary: #{ @@client }\n" \
             "  Make sure it's in your \$PATH or tell Sqitch where to find it by running:\n\n" \
             "      sqitch config --user engine.snowflake.client #{ @@client }\n\n"
    end

    # Show missing items.
    if !@have_dylib
      msg += "- Cannot find ODBC Driver: File not found:\n\n" \
             "    #{ @@dylib }\n\n" \
             "  Download from:\n\n" \
             "    #{ download }\n\n"
    end
    if !@have_client
      msg += "- SnowSQL not found; installation instructions:\n\n" \
             "    https://docs.snowflake.net/manuals/user-guide/snowsql-install-config.html\n\n" \
             "  Once it's installed, make sure it's in your \$PATH or tell Sqitch\n" \
             "  where to find it by running:\n\n" \
             "      sqitch config --user engine.snowflake.client /path/to/snowsql\n\n"
    end
    return msg
  end
end
