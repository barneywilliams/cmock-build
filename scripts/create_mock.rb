require 'cmock'

raise "Header file to mock must be specified!" unless ARGV.length >= 1

root = File.expand_path(File.join(File.dirname(__FILE__), '../'))
mock_out = ENV.fetch('MOCK_OUT', File.join(root, 'build/test/mocks'))
mock_prefix = ENV.fetch('MOCK_PREFIX', 'mock_')
cmock = CMock.new(plugins: [:ignore, :return_thru_ptr], mock_prefix: 'mock_', mock_path: mock_out)
cmock.setup_mocks(ARGV[0])
