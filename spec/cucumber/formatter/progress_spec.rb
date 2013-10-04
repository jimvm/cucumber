require 'spec_helper'
require 'cucumber/ast/step_result'
require 'cucumber/formatter/progress'

module Cucumber
  module Formatter
    describe Progress do
      before        { Cucumber::Term::ANSIColor.coloring = false }
      let(:out)     { StringIO.new }
      let(:visitor) { Cucumber::Ast::TreeWalker.new(nil, [subject]) }
      subject       { Progress.new(nil, out, {}) }

      describe 'visiting a table cell value without a status' do
        # TODO: this seems bizarre. Why not just mark the cell as skipped or noop?
        it 'should take the status from the last run step' do
          step_result = Ast::StepResult.new('', '', nil, :failed, nil, 10, nil, nil)
          step_result.accept(visitor)
          visitor.visit_outline_table(double) do
            visitor.visit_table_cell_value('value', nil)
          end
          out.string.should == 'FF'
        end
      end

      describe 'visiting a table cell which is a table header' do
        it 'should not output anything' do
          visitor.visit_table_cell_value('value', :skipped_param)
          out.string.should be_empty
        end
      end
    end
  end
end
