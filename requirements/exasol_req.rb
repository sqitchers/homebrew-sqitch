require "requirement"

class ExasolReq < Requirement
  @@dylib = "/Library/ODBC/EXASolution\ ODBC.bundle/Contents/MacOS/libexaodbc-*.dylib"
  @@client = "/Applications/EXAplus.app/Contents/MacOS/EXAplus"
  @have_client = false
  @have_dylib = false
  fatal false
  download "https://www.exasol.com/portal/display/DOWNLOAD/"

  def initialize(tags = [])
    super
    @name = "Exasol"
    @have_dylib = !Dir.glob(@@dylib).empty?
    @have_client = File.executable?(@@client)
   end

  satisfy(build_env: false) { @have_dylib }

  def message
    <<~EOS
      Sqitch Exasol support requires the Exasol ODBC Driver and EXAplus client.
      Downloads: #{ download }
    EOS
  end

  def notes
    msg = "Exasol support requires the ODBC Driver and EXAplus client\n\n"
    # Show found items.
    if @have_dylib
      msg += "- Found Driver matching:\n  #{ @@dylib }\n\n"
    end
    if @have_client
      msg += "- Found EXAplus:\n  #{ @@client }\n" \
             "  Make sure it's in your \$PATH or tell Sqitch where to find it by running:\n\n" \
             "      sqitch config --user engine.exasol.client \"#{ @@client }\"\n\n"
    end

    # Show missing items.
    if !@have_dylib
      msg += "- Cannot find ODBC Driver: No file found matching\n\n" \
             "    #{ @@dylib }\n\n" \
             "  Download from:\n\n" \
             "    #{ download }\n\n"
    end
    if !@have_client
      msg += "- Cannot find client binary:\n  #{ @@client }\n" \
             "  Download from:\n\n" \
             "    #{ download }\n\n" \
             "  Once it's installed, make sure it's in your \$PATH or tell Sqitch\n" \
             "  where to find it by running:\n\n" \
             "      sqitch config --user engine.exasol.client /path/to/exaplus\n\n"
    end
    return msg
  end
end
