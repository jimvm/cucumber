require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/pretty'
require 'cucumber/cli/options'

module Cucumber
  module Formatter
    describe Pretty do
      extend SpecHelperDsl
      include SpecHelper

      before { Cucumber::Term::ANSIColor.coloring = false }
      let(:out) { StringIO.new }

      before(:each) { run_defined_feature }

      context "With no options" do
        subject { Pretty.new(runtime, out, {}) }

        describe "given a single feature" do

          describe "basic feature" do
            define_feature <<-FEATURE
            Feature: Bananas
              In order to find my inner monkey
              As a human
              I must eat bananas
            FEATURE

            it "prints out the feature description" do
              out.string.should include "Feature: Bananas"
              out.string.should include "I must eat bananas"
            end

          end

          describe "with a scenario" do
            define_feature <<-FEATURE
          Feature: Banana party

            Scenario: Monkey eats banana
              Given there are bananas
            FEATURE

            it "outputs the scenario name" do
              out.string.should include "Scenario: Monkey eats banana"
            end
            it "outputs the step" do
              out.string.should include "Given there are bananas"
            end
          end

          describe "with a scenario outline" do
            define_feature <<-FEATURE
          Feature: Fud Pyramid

            Scenario Outline: Monkey eats a balanced diet
              Given there are <Things>

              Examples: Fruit
               | Things  |
               | apples  |
               | bananas |
              Examples: Vegetables
               | Things   |
               | broccoli |
               | carrots  |
            FEATURE

            it "outputs the scenario outline" do
              lines = <<-OUTPUT
              Examples: Fruit
               | Things  |
               | apples  |
               | bananas |
              Examples: Vegetables
               | Things   |
               | broccoli |
               | carrots  |
              OUTPUT
              lines.split("\n").each do |line|
                out.string.should include line.strip
              end
            end
            it "has 4 undefined scenarios" do
              out.string.should include "4 scenarios (4 undefined)"
            end
            it "has 4 undefined steps" do
              out.string.should include "4 steps (4 undefined)"
            end

          end

          # To ensure https://rspec.lighthouseapp.com/projects/16211/tickets/475 remains fixed.
          describe "with a scenario outline with a pystring" do
            define_feature <<-FEATURE
          Feature:
            Scenario Outline: Monkey eats a balanced diet
              Given a multiline string:
                """
                Monkeys eat <things>
                """

              Examples:
               | things |
               | apples |
            FEATURE

            it "outputs the scenario outline" do
              lines = <<-OUTPUT
              Given a multiline string:
                """
                Monkeys eat <things>
                """

              Examples:
               | things |
               | apples |
              OUTPUT
              lines.split("\n").each do |line|
                out.string.should include line.strip
              end
            end
          end

          describe "with a step with a py string" do
            define_feature <<-FEATURE
          Feature: Traveling circus

            Scenario: Monkey goes to town
              Given there is a monkey called:
               """
               foo
               """
            FEATURE

            it "displays the pystring nested" do
              out.string.should include <<OUTPUT
      """
      foo
      """
OUTPUT
            end
          end

          describe "with a multiline step arg" do
            define_feature <<-FEATURE
          Feature: Traveling circus

            Scenario: Monkey goes to town
              Given there are monkeys:
               | name |
               | foo  |
               | bar  |
            FEATURE

            it "displays the multiline string" do
              out.string.should include <<OUTPUT
    Given there are monkeys:
      | name |
      | foo  |
      | bar  |
OUTPUT
            end
          end

          describe "with a table in the background and the scenario" do
            define_feature <<-FEATURE
          Feature: accountant monkey

            Background:
              Given table:
                | a | b |
                | c | d |
            Scenario:
              Given another table:
               | e | f |
               | g | h |
            FEATURE

            it "displays the table for the background" do
              out.string.should include <<OUTPUT
    Given table:
      | a | b |
      | c | d |
OUTPUT
            end
            it "displays the table for the scenario" do
              out.string.should include <<OUTPUT
    Given another table:
      | e | f |
      | g | h |
OUTPUT
            end
          end

          describe "with a py string in the background and the scenario" do
            define_feature <<-FEATURE
          Feature: py strings

            Background:
              Given stuff:
                """
                foo
                """
            Scenario:
              Given more stuff:
                """
                bar
                """
            FEATURE

            it "displays the background py string" do
              out.string.should include <<OUTPUT
    Given stuff:
      """
      foo
      """
OUTPUT
            end
            it "displays the scenario py string" do
              out.string.should include <<OUTPUT
    Given more stuff:
      """
      bar
      """
OUTPUT
            end
          end
        end
      end

      context "With --no-multiline passed as an option" do
        subject { Pretty.new(runtime, out, {:no_multiline => true}) }

        describe "given a single feature" do

          describe "basic feature" do
            define_feature <<-FEATURE
            Feature: Bananas
              In order to find my inner monkey
              As a human
              I must eat bananas
            FEATURE

            it "prints out the feature description" do
              out.string.should include "Feature: Bananas"
              out.string.should include "I must eat bananas"
            end

          end

          describe "with a scenario" do
            define_feature <<-FEATURE
          Feature: Banana party

            Scenario: Monkey eats banana
              Given there are bananas
            FEATURE

            it "outputs the scenario name" do
              out.string.should include "Scenario: Monkey eats banana"
            end
            it "outputs the step" do
              out.string.should include "Given there are bananas"
            end
          end

          describe "with a scenario outline" do
            define_feature <<-FEATURE
          Feature: Fud Pyramid

            Scenario Outline: Monkey eats a balanced diet
              Given there are <Things>

              Examples: Fruit
               | Things  |
               | apples  |
               | bananas |
              Examples: Vegetables
               | Things   |
               | broccoli |
               | carrots  |
            FEATURE

            it "outputs the scenario outline" do
              lines = <<-OUTPUT
              Examples: Fruit
               | Things  |
               | apples  |
               | bananas |
              Examples: Vegetables
               | Things   |
               | broccoli |
               | carrots  |
              OUTPUT
              lines.split("\n").each do |line|
                out.string.should include line.strip
              end
            end
            it "has 4 undefined scenarios" do
              out.string.should include "4 scenarios (4 undefined)"
            end
            it "has 4 undefined steps" do
              out.string.should include "4 steps (4 undefined)"
            end
          end

          describe "with a step with a py string" do
            define_feature <<-FEATURE
          Feature: Traveling circus

            Scenario: Monkey goes to town
              Given there is a monkey called:
               """
               foo
               """
            FEATURE

            it "does not display the pystring" do
              out.string.should_not include <<OUTPUT
      """
      foo
      """
OUTPUT
            end
          end

          describe "with a multiline step arg" do
            define_feature <<-FEATURE
          Feature: Traveling circus

            Scenario: Monkey goes to town
              Given there are monkeys:
               | name |
               | foo  |
               | bar  |
            FEATURE

            it "does not display the multiline string" do
              out.string.should_not include <<OUTPUT
      | name |
      | foo  |
      | bar  |
OUTPUT
            end
          end

          describe "with a table in the background and the scenario" do
            define_feature <<-FEATURE
          Feature: accountant monkey

            Background:
              Given table:
                | a | b |
                | c | d |
            Scenario:
              Given another table:
               | e | f |
               | g | h |
            FEATURE

            it "does not display the table for the background" do
              out.string.should_not include <<OUTPUT
      | a | b |
      | c | d |
OUTPUT
            end
            it "does not display the table for the scenario" do
              out.string.should_not include <<OUTPUT
      | e | f |
      | g | h |
OUTPUT
            end
          end

          describe "with a py string in the background and the scenario" do
            define_feature <<-FEATURE
          Feature: py strings

            Background:
              Given stuff:
                """
                foo
                """
            Scenario:
              Given more stuff:
                """
                bar
                """
            FEATURE

            it "does not display the background py string" do
              out.string.should_not include <<OUTPUT
      """
      foo
      """
OUTPUT
            end
            it "does not display the scenario py string" do
              out.string.should_not include <<OUTPUT
      """
      bar
      """
OUTPUT
            end
          end
        end
      end

    end
  end
end
