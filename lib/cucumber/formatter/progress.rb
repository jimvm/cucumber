require 'cucumber/formatter/console'
require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format progress</tt>
    class Progress
      include Console
      include Io
      attr_reader :runtime, :exception_raised, :status

      def initialize(runtime, path_or_io, options)
        @runtime, @io, @options = runtime, ensure_io(path_or_io, "progress"), options
      end

      def before_features(*features)
        print_profile_information
      end

      def after_features(features)
        @io.puts
        @io.puts
        print_summary(features)
      end

      def after_feature_element(*args)
        progress(:failed) if @exception_raised
      end

      def before_steps(*args)
        progress(:failed) if @exception_raised
      end

      def after_step_result(step_result)
        progress(step_result.status)
        @status = step_result.status
      end

      def before_outline_table(outline_table)
        @outline_table = outline_table
      end

      def after_outline_table(outline_table)
        @outline_table = nil
      end

      def table_cell_value(value, status)
        return unless @outline_table
        status ||= @status
        progress(status) unless table_header_cell?(status)
      end

      def exception(*args)
        @exception_raised = true
      end

      private

      def print_summary(features)
        print_steps(:pending)
        print_steps(:failed)
        print_stats(features, @options)
        print_snippets(@options)
        print_passing_wip(@options)
      end

      CHARS = {
        :passed    => '.',
        :failed    => 'F',
        :undefined => 'U',
        :pending   => 'P',
        :skipped   => '-'
      }

      def progress(status)
        char = CHARS[status]
        @io.print(format_string(char, status))
        @io.flush
        reset_exception(status)
      end

      def table_header_cell?(status)
        status == :skipped_param
      end

      def reset_exception(status)
        @exception_raised = false if status == :failed
      end
    end
  end
end
