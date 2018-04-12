# encoding: utf-8

module LogStash
  class SnmpMib


    def initialize
      @by_name = {}
      @by_oid = {}
      @by_module = {}
      # @mib_paths = Array(mibs_paths)
    end

    # def add_mib(module_name)
    #   @mib_paths.each do |path|
    #     dic_files = Dir[File.join(path, "*.dic")]
    #     dic.files.each do |file|
    #       if // ~= file
    #         module_name, name_hash, oid_hash = read_mib_dic(file)
    #
    #         @by_name = @by_name.merge(name_hash) do |key, old, value|
    #           warn "warning: overwriting old MIB name '#{key}'"
    #         end
    #       end
    #     end
    #   end
    # end

    def read_mib_dic(filename)
      mib_dic = IO.read(filename)
      mib = eval_mib_dic(mib_dic)
      raise("invalid mib dic format for file #{filename}") unless mib
      module_name = mib["moduleName"]
      raise("invalid mib dic format for file #{filename}") unless module_name
      nodes = mib["nodes"]
      raise("no nodes defined in mib dic file #{filename}") unless nodes

      # name_hash is { mib-name => oid }
      name_hash = {}
      nodes.each { |k, v| name_hash[k] = v["oid"] }
      if mib["notifications"]
        mib["notifications"].each { |k, v| name_hash[k] = v["oid"] }
      end

      # oid_hash is inverted name_hash; { oid => [module-name, mib-name]}
      # oid_hash = name_hash.inject({}) { |result, (k, v)| result[v] = [module_name, k]; result }
      oid_hash = name_hash.invert

      [module_name, name_hash, oid_hash]
    end

    private

    def eval_mib_dic(mib_dic)
      mib_hash = mib_dic.
        gsub(':', '=>').                  # fix hash syntax
        gsub('(', '[').gsub(')', ']').    # fix tuple syntax
        sub('FILENAME =', 'filename =').  # get rid of constants
        sub('MIB =', 'mib =')

      mib = nil
      eval(mib_hash)
      mib
    end

  end
end
