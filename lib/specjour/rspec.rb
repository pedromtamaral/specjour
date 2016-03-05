module Specjour
  module RSpec
    require 'rspec/core'
    require 'rspec/core/formatters/progress_formatter'

    require 'specjour/rspec/marshalable_exception'
    require 'specjour/rspec/preloader'
    if Specjour.rspec2?
      require 'specjour/rspec/distributed_formatter_rspec2'
    else
      require 'specjour/rspec/distributed_formatter'
    end
    require 'specjour/rspec/final_report'
    require 'specjour/rspec/runner'
    require 'specjour/rspec/shared_example_group_ext'

    ::RSpec::Core::Runner.disable_autorun!
    ::RSpec::Core::Runner.class_eval "def self.trap_interrupt;end"
    ::RSpec.class_eval "def self.reset; world.reset; configuration.reset; end"
  end
end
