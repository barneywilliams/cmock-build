require 'cmock'
require 'fileutils'
root = File.expand_path(File.join(File.dirname(__FILE__), '../'))
unity_abs_root = File.join(root, 'vendor', 'cmock', 'vendor', 'unity')
require "#{unity_abs_root}/auto/unity_test_summary.rb"

build_dir = ENV.fetch('BUILD_DIR', './build')
test_build_dir = ENV.fetch('TEST_BUILD_DIR', File.join(build_dir, 'test'))
test_bin_dir = File.join(test_build_dir, 'bin')

parser = UnityTestSummary.new
results = Dir["#{test_bin_dir}/*.result"]
parser.set_targets(results)
parser.run
puts parser.report
exit(parser.failures)
