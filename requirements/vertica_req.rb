class VerticaReq < Requirement
  @@dylib = "/Library/Vertica/ODBC/lib/libverticaodbc.dylib"
  @@client = "/opt/vertica/bin/vsql"
  @have_client = false
  @have_dylib = false
  fatal false
  download "https://www.vertica.com/download/vertica/client-drivers/"

  def initialize(tags = [])
    super
    @name = "Vertica"
    @have_dylib = File.exist?(@@dylib)
    @have_client = File.executable?(@@client)
   end

  satisfy(build_env: false) { @have_dylib }

  def message
    <<~EOS
      Sqitch Vertica support requires the Vertica ODBC Driver and vsql client.
      Downloads: #{download}
    EOS
  end

  def notes
    msg = "Vertica support requires the ODBC Driver and vsql client\n\n"
    # Show found items.
    if @have_dylib
      msg +=  "- Found Driver #{@@dylib}\n"
    end
    if @have_client
      msg += "- Found vsql: #{@@client}\n" \
             "  Make sure it's in your \$PATH or tell Sqitch where to find it by running:\n\n" \
             "      sqitch config --user engine.vertica.client #{@@client}\n\n"
    end

    # Show missing items.
    if !@have_dylib
      msg += "- Cannot find ODBC Driver: File not found:\n\n" \
             "    #{@@dylib}\n\n" \
             "  Download from:\n\n" \
             "    #{download}\n\n"
    end
    if !@have_client
      msg += "- Cannot find client binary: #{@@client}\n" \
             "  Download from:\n\n" \
             "    #{download}\n\n" \
             "  Once it's installed, make sure it's in your \$PATH or tell Sqitch\n" \
             "  where to find it by running:\n\n" \
             "      sqitch config --user engine.vertica.client /path/to/vsql\n\n"
    end
    return msg
  end
end
