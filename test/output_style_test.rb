# frozen_string_literal: true

require_relative "test_helper"

module DartSass
  class OutputStyleTest < MiniTest::Test
    def input_scss
      <<~CSS
        $color: #fff;
        
        #main {
          color: $color;
          background-color: #000;
          p {
            width: 10em;
          }
        }
        
        .huge {
          font-size: 10em;
          font-weight: bold;
          text-decoration: underline;
        }
      CSS
    end

    def expected_expanded_output
      <<~CSS.chomp
        #main {
          color: #fff;
          background-color: #000;
        }
        #main p {
          width: 10em;
        }
        
        .huge {
          font-size: 10em;
          font-weight: bold;
          text-decoration: underline;
        }
      CSS
    end

    def test_expanded_output_is_default
      engine = Engine.new(input_scss)
      assert_equal expected_expanded_output, engine.render
    end

    def test_output_style_accepts_strings
      engine = Engine.new(input_scss, style: "sass_style_expanded")
      assert_equal expected_expanded_output, engine.render
    end

    def test_invalid_output_style
      engine = Engine.new(input_scss, style: "totally_wrong")
      assert_raises(InvalidStyleError) { engine.render }
    end

    def test_nested_output_uses_expanded
      # nested output not support by dart sass
      engine = Engine.new(input_scss, style: :sass_style_nested)
      assert_equal expected_expanded_output, engine.render
    end

    def test_expanded_output
      engine = Engine.new(input_scss, style: :sass_style_expanded)
      assert_equal <<~CSS.chomp, engine.render
        #main {
          color: #fff;
          background-color: #000;
        }
        #main p {
          width: 10em;
        }
        
        .huge {
          font-size: 10em;
          font-weight: bold;
          text-decoration: underline;
        }
      CSS
    end

    def test_compact_output_uses_expanded
      # nested output not support by dart sass
      engine = Engine.new(input_scss, style: :sass_style_compact)
      assert_equal expected_expanded_output, engine.render
    end

    def test_compressed_output
      engine = Engine.new(input_scss, style: :sass_style_compressed)
      assert_equal <<~CSS.chomp, engine.render
        #main{color:#fff;background-color:#000}#main p{width:10em}.huge{font-size:10em;font-weight:bold;text-decoration:underline}
      CSS
    end

    def test_short_output_style_names
      engine = Engine.new(input_scss, style: :compressed)
      assert_equal <<~CSS.chomp, engine.render
        #main{color:#fff;background-color:#000}#main p{width:10em}.huge{font-size:10em;font-weight:bold;text-decoration:underline}
      CSS
    end
  end
end
