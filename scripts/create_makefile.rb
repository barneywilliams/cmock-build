require 'cmock'
require 'fileutils'
root = File.expand_path(File.join(File.dirname(__FILE__), '../'))
unity_abs_root = File.join(root, 'vendor', 'cmock', 'vendor', 'unity')
require "#{unity_abs_root}/auto/generate_test_runner"

src_dir =  ENV.fetch('SRC_DIR',  './src')
test_dir = ENV.fetch('TEST_DIR', './test')
unity_dir = ENV.fetch('UNITY_DIR', './vendor/cmock/vendor/unity')
unity_src = "#{unity_dir}/src"
build_dir = ENV.fetch('BUILD_DIR', './build')
test_bin_dir = ENV.fetch('TEST_BIN_DIR', "#{build_dir}/test/bin")
obj_dir = File.join(build_dir, 'obj')
unity_obj = File.join(obj_dir, 'unity.o')
runners_dir = File.join(build_dir, 'test/runners')
mock_prefix = ENV.fetch('MOCK_PREFIX', 'mock_')
mock_out = File.join(build_dir, 'test/mocks')
MOCK_MATCHER = /#{mock_prefix}[A-Za-z_][A-Za-z0-9_\-\.]+/

all_headers_to_mock = []

File.open("build/MakefileTestSupport", "w") do |mkfile|

  mkfile.puts "#{unity_obj}: #{unity_src}/unity.c"
  mkfile.puts "\t${CC} -o $@ -c $< -I #{unity_src}"
  mkfile.puts ""

  test_sources = Dir["#{test_dir}/**/test_*.c"]
  generator = UnityTestRunnerGenerator.new
  all_headers = Dir["#{src_dir}/**/*.h"]

  test_sources.each do |test|
    module_name = File.basename(test, '.c')
    src_module_name = module_name.sub(/^test_/, '')

    module_src = File.join(src_dir, "#{src_module_name}.c")
    module_obj = File.join(obj_dir, "#{src_module_name}.o")
    mkfile.puts "#{module_obj}: #{module_src}"
    mkfile.puts "\t${CC} -o $@ -c $< -I #{src_dir}"
    mkfile.puts ""

    runner_source = File.join(runners_dir, "runner_#{module_name}.c")
    runner_obj = File.join(obj_dir, "runner_#{module_name}.o")
    test_obj = File.join(obj_dir, "#{module_name}.o")

    mkfile.puts "#{runner_source}: #{test}"
    mkfile.puts "\truby scripts/create_runner.rb #{test} #{runner_source}"
    mkfile.puts ""

    mkfile.puts "#{runner_obj}: #{runner_source}"
    mkfile.puts "\t${CC} -o $@ -c $< -I #{src_dir} -I #{unity_src}"
    mkfile.puts ""

    cfg = {
      src: test,
      includes: generator.find_includes(File.readlines(test).join(''))
    }
    system_mocks = cfg[:includes][:system].select{|name| name =~ MOCK_MATCHER}
    raise "Mocking of system headers is not yet supported!" if !system_mocks.empty?
    local_mocks = cfg[:includes][:local].select{|name| name =~ MOCK_MATCHER}
    module_names_to_mock = local_mocks.map{|name| "#{name.sub(/#{mock_prefix}/,'')}.h"}
    headers_to_mock = []
    module_names_to_mock.each do |name|
      header_to_mock = nil
      all_headers.each do |header|
        if (header =~ /[\/\\]?#{name}$/)
          header_to_mock = header
          break
        end
      end
      raise "Module header '#{name}' not found to mock!" unless header_to_mock
      headers_to_mock << header_to_mock 
    end
    all_headers_to_mock += headers_to_mock

    mkfile.puts "#{test_obj}: #{test} #{module_obj}"
    mkfile.puts "\t${CC} -o $@ -c $< -I #{src_dir} -I #{unity_src}"
    mkfile.puts ""

    test_bin = File.join(test_bin_dir, module_name)
    test_objs = "#{test_obj} #{runner_obj} #{module_obj} #{unity_obj}"
    mkfile.puts "#{test_bin}: #{test_objs}"
    mkfile.puts "\t${CC} -o $@ #{test_objs}"
    mkfile.puts ""
  end
end

puts "Headers to mock: #{all_headers_to_mock.join(', ')}"
