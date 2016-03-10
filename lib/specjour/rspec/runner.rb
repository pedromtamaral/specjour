module Specjour::RSpec::Runner
  ::RSpec.configuration.backtrace_clean_patterns << %r(lib/specjour/) if Specjour.rspec2?

  def self.run(spec, output)
    if Specjour.rspec2?
      args = ['--format=Specjour::RSpec::DistributedFormatterRspec2', spec]
    else
      args = ['--format=Specjour::RSpec::DistributedFormatter', spec]
    end
    ::RSpec.configuration.output_stream = output unless Specjour.rspec2? && !Specjour.rspec2_99?
    ::RSpec::Core::Runner.run args, $stderr, output
  ensure
    ::RSpec.configuration.filter_manager = ::RSpec::Core::FilterManager.new
    ::RSpec.world.filtered_examples.clear
    ::RSpec.world.inclusion_filter.clear
    ::RSpec.world.exclusion_filter.clear
    ::RSpec.world.send(:instance_variable_set, :@line_numbers, nil)
  end
end
