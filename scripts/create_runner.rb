if ($0 == __FILE__)

  #make sure there is at least one parameter left (the input file)
  if ARGV.length < 2
    puts ["\nusage: ruby #{__FILE__} input_test_file (output)",
      "",
      "  input_test_file         - this is the C file you want to create a runner for",
      "  output                  - this is the name of the runner file to generate",
      "                            defaults to (input_test_file)_Runner",
    ].join("\n")
    exit 1
  end

  require 'cmock'
  require 'fileutils'
  root = File.expand_path(File.join(File.dirname(__FILE__), '../'))
  src_dir =  ENV.fetch('SRC_DIR',  File.join(root, 'src'))
  test_dir = ENV.fetch('TEST_DIR', File.join(root, 'test'))
  runners_dir = ENV.fetch('RUNNERS_DIR', File.join(root, 'build/runners'))
  require "#{root}/vendor/cmock/vendor/unity/auto/generate_test_runner"

  test = ARGV[0]
  runner = ARGV[1]

  generator = UnityTestRunnerGenerator.new

  generator.run(test, runner)

end
