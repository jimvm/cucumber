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

      describe '#before_features' do
        subject { Progress.new(nil, out, {:profiles => ['whatever']}) }

        # This tests Console implementation and not very thoroughly.
        it 'prints out profile information' do
          subject.before_features
          out.string.should == "Using the whatever profile...\n"
        end
      end

      describe '#after_features' do
        let(:features) { Cucumber::Ast::Features.new }
        subject        { Progress.new(Runtime.new, out, {}) }

        # This tests Console implementation and not very thoroughly.
        it 'prints out a summary' do
          subject.after_features features
          out.string.should == "\n\n0 scenarios\n0 steps\n"
        end
      end

      describe '#before_feature_element' do
        it 'sets exception_raised to false' do
          subject.before_feature_element
          subject.exception_raised.should be_false
        end
      end

      describe '#after_feature_element' do
        context 'when an exception is raised' do
          before { subject.exception }

          it 'prints out an "F"' do
            subject.after_feature_element
            out.string.should == 'F'
          end

          it 'cleans up exception state' do
            expect { subject.after_feature_element }.
              to change { subject.exception_raised }.from(true).to(false)
          end
        end

        context 'when no exception is raised' do
          it 'prints out nothing' do
            subject.after_feature_element
            out.string.should be_empty
          end
        end
      end

      describe '#before_steps' do
        context 'when an exception is raised' do
          before { subject.exception }

          it 'prints out an "F"' do
            subject.before_steps
            out.string.should == 'F'
          end

          it 'cleans up exception state' do
            expect { subject.before_steps }.
              to change { subject.exception_raised }.from(true).to(false)
          end
        end

        context 'when no exception is raised' do
          it 'prints out nothing' do
            subject.before_steps
            out.string.should be_empty
          end
        end
      end

      describe '#after_steps' do
        before { subject.after_steps }

        it 'sets exception_raised to "false"' do
          subject.exception_raised.should be_false
        end
      end

      describe '#after_step_result' do
        let(:step_result) { double }

        before do
          step_result.stub(:status) { :passed }
          subject.after_step_result step_result
        end

        it 'prints out the correct status character' do
          out.string.should == '.'
        end

        it 'sets status as the given status' do
          subject.status.should == :passed
        end
      end

      describe '#table_cell_value' do
        before { subject.before_outline_table(true) }

        it 'prints out the current status character' do
          subject.table_cell_value(nil, :undefined)
          out.string.should == 'U'
        end

        context 'when the status is ":skipped_param"' do
          before { subject.table_cell_value(nil, :skipped_param) }

          it 'does not print out anything' do
            out.string.should be_empty
          end
        end
      end

      describe '#exception' do
        before { subject.exception }

        it 'sets exception_raised to "true"' do
          subject.exception_raised.should be_true
        end
      end
    end
  end
end
