require 'cmock'

root = File.expand_path(File.join(File.dirname(__FILE__), '../'))
mock_out = ENV.fetch('MOCK_OUT', File.join(root, 'build/mocks'))
cmock = CMock.new(plugins: [:ignore, :return_thru_ptr], mock_prefix: 'mock_', mock_path: mock_out)
src_dir = ENV.fetch('SRC_DIR', File.join(root, 'src'))
headers_to_mock = Dir["#{src_dir}/*.h"]
puts "\nCreating mocks from header files...\n-----------------------------------"
cmock.setup_mocks(headers_to_mock)
puts "\nGenerated Mocks:\n----------------"
Dir["#{mock_out}/mock_*.h"].each{|mock| puts mock}
