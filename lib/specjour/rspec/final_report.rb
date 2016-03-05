module Specjour::RSpec
  class FinalReport
    attr_reader :examples
    attr_reader :duration

    def initialize
      @examples = []
      @duration = 0.0
      ::RSpec.configuration.output_stream = $stdout
    end

    def add(data)
      if data.respond_to?(:has_key?) && data.has_key?(:duration)
        self.duration = data[:duration]
      else
        metadata_for_examples(data)
      end
    end

    def duration=(value)
      @duration = value.to_f if duration < value.to_f
    end

    def exit_status
      failed_examples.empty?
    end

    def metadata_for_examples(metadata_collection)
      new_examples = begin
        (metadata_collection || []).map do |partial_metadata|
          ::RSpec::Core::Example.allocate.tap do |example|
            if Specjour.rspec2?
              struct = OpenStruct.new(:metadata => {}, :ancestors => [], :parent_groups => [])
              example.instance_variable_set(:@example_group_class, struct)
              metadata = ::RSpec::Core::Metadata.new
              metadata.merge! partial_metadata
            else
              metadata = ::RSpec::Core::Metadata.build_hash_from([partial_metadata])
            end
            example.instance_variable_set(:@metadata, metadata)
          end
        end
      end

      examples.concat(new_examples)
    end

    def pending_examples
      examples.select {|e| e.execution_result[:status].to_s == 'pending'}
    end

    def failed_examples
      examples.select {|e| e.execution_result[:status].to_s == 'failed'}
    end

    def summarize
      # puts "\nFinished in #{duration} seconds" # TODO: could not get this yet
      puts "#{examples.size} examples, #{failed_examples.size} failed, #{pending_examples.size} pending.\n"
      if pending_examples.size > 0
        puts "\nPending examples:\n"
        pending_examples.each do |example|
          puts "rspec #{example.location} # #{example.description}"
        end
      end
      if failed_examples.size > 0
        puts "\nFailed examples:\n"
        failed_examples.each do |example|
          puts "rspec #{example.location} # #{example.description}"
        end
      end
    end
  end
end
