module Specjour::RSpec
  class DistributedFormatter
    RSpec::Core::Formatters.register self, :dump_summary
    attr_reader :output

    def initialize(output)
      @output = output
    end

    def dump_summary(summary)
      output.send_message(:rspec_summary=, metadata_for_examples(summary.examples))
    end

    def metadata_for_examples(examples)
      examples.map do |example|

        metadata = begin
          if example_is_shared?(example)
            example.example_group.metadata
          else
            example.metadata
          end
        end

        {
          :execution_result => marshalable_execution_result(example.execution_result),
          :description => metadata[:description],
          :file_path => metadata[:file_path],
          :full_description => metadata[:full_description],
          :line_number => metadata[:line_number],
          :location => metadata[:location]
        }
      end
    end

    protected

    def example_is_shared?(example)
      example.instance_variable_get(:"@example_group_class").name.split("::").last.start_with?("ItShouldBehaveLike")
    end

    def marshalable_execution_result(execution_result)
      {
        :exception => execution_result.exception ? MarshalableException.new(execution_result.exception) : nil,
        :status => execution_result.status,
        :started_at => Time.at(execution_result.started_at),
        :finished_at => Time.at(execution_result.finished_at)
      }
    end

  end
end
