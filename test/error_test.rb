# frozen_string_literal: true

require_relative "test_helper"

module DartSass
  class ErrorTest < MiniTest::Test
    def render(data, opts = {})
      Engine.new(data, opts).render
    end

    def test_first_backtrace_is_sass
      filename = "app/assets/stylesheets/application.scss"

      begin
        template = <<~SCSS
          .foo {
            baz: bang;
            padding top: 10px;
          }
        SCSS

        render(template, filename: filename)
      rescue SyntaxError => err
        expected = "#{filename}:2"
        assert_equal expected, err.backtrace.first
      end
    end
  end
end
