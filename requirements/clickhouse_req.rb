class ClickHouseReq < Requirement
  @client = nil
  @@docs  = "https://clickhouse.com/docs/install"

  def initialize(tags = [])
    super
    @name = "ClickHouse"
    @client = _find_client
  end

  def _have_client
    # https://stackoverflow.com/a/5471032/79202
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      ['clickhouse', 'clickhouse-client'].each do |bin|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        end
      end
    end
    nil
  end

  def notes
    msg = "ClickHouse support requires the clickhouse or clickhouse-client binary\n\n"
    if @client
      msg += "- Found ClickHouse client: #{@client}\n"
    else
      msg += "- ClickHouse client not found; installation instructions:\n\n" \
             "    #{@@docs}\n\n" \
             "  Once it's installed, make sure it's in your \$PATH or tell Sqitch\n" \
             "  where to find it by running:\n\n" \
             "      sqitch config --user engine.clickhouse.client /path/to/clickhouse\n\n"
    end
    return msg
  end
end
