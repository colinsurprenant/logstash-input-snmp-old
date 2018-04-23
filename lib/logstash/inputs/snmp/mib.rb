# encoding: utf-8

module LogStash
  class SnmpMibError < StandardError
  end

  class SnmpMib

    class Node
      attr_reader :node_type, :module_name, :oid, oid_path, :childs

      def inititalize(node_type, module_name, oid)
        @node_type = node_type
        @module_name = module_name
        @oid = oid
        @oid_path = parse_oid(oid)
        @childs = []
      end

      private

      def parse_oid(oid)
        path = oid.split(".")
        raise(SnmpMibError, "invalid oid '#{oid}'") if path.empty?
        path
      end
    end

    class Tree
      def initialize
        @root = Node.new("root", "root", 0)
      end

      def add_node(node)
        current = @root

        node.oid_path.each do

        end
      end
    end

    def initialize
      @by_name = {}
      @by_oid = {}

      @root_node = nil
    end

    # add a specific mib dic file or all mib dic files of the given directory to the current mib database
    # @param path [String] a file or directory path to mib dic file(s)
    # @return [Array] array of warning strings if any OID or name has been overwritten or the empty array when no warning
    def add_mib_path(path)

      dic_files = if ::File.directory?(path)
        Dir[::File.join(path, "*.dic")]
      elsif ::File.file?(path)
        [path]
      else
        raise(SnmpMibError, "file or directory path expected: #{path.to_s}")
      end

      warnings = []
      dic_files.each do |f|
        module_name, name_hash, oid_hash = read_mib_dic(f)
        @by_name = @by_name.merge(name_hash) do |key, old, value|
          if (old != value)
            warnings << "warning: overwriting MIB name '#{key}' and OID '#{old}' with new OID '#{value}' from module '#{module_name}'"
          end
        end
        @by_oid = @by_oid.merge(oid_hash) do |key, old, value|
          if (old != value)
            warnings << "warning: overwriting MIB OID '#{key}' and name '#{old}' with new name '#{value}' from module '#{module_name}'"
          end
        end
      end

      warnings
    end

    # read and parse a mib dic file
    #
    # @param filename [String] file path of a mib dic file
    # @return [[String, Hash, Hash]] the 3-tuple of the mib module name, the name-to-OID hash and the OID-to-name hash
    def read_mib_dic(filename)
      mib = eval_mib_dic(filename)
      raise(SnmpMibError, "invalid mib dic format for file #{filename}") unless mib
      module_name = mib["moduleName"]
      raise(SnmpMibError, "invalid mib dic format for file #{filename}") unless module_name
      nodes = mib["nodes"]
      raise(SnmpMibError, "no nodes defined in mib dic file #{filename}") unless nodes

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

    def find_oid(oid)
      @by_oid[oid]
    end

    def find_name(name)
      @by_name[name]
    end

    private

    def eval_mib_dic(filename)
      mib_dic = IO.read(filename)
      mib_hash = mib_dic.
        gsub(':', '=>').                  # fix hash syntax
        gsub('(', '[').gsub(')', ']').    # fix tuple syntax
        sub('FILENAME =', 'filename =').  # get rid of constants
        sub('MIB =', 'mib =')

      mib = nil
      eval(mib_hash)
      mib
    rescue => e
      raise(SnmpMibError, "error parsing mib dic file: #{filename}, error: #{e.message}")
    end

  end
end
