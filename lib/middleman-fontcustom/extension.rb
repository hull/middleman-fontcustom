require 'fontcustom'

module Middleman
  class FontcustomExtension < Extension
    option :font_name, 'fontcustom', 'Output font name'
    option :source_dir, 'assets/fontcustom', 'Folder contains icon files'
    option :fonts_dir, 'source/fonts', 'Folder to output fonts'
    option :css_dir, 'source/stylesheets', 'Folder to output css'

    option :css_prefix, 'glyphicon-{{glyph}}', 'Glyph Prefix'
    option :autowidth, true, 'Autowidth Glyphs'
    option :font_design_size, 32, 'Original Glyph Size'
    option :font_em, 1800, 'Scaling Font'
    option :font_ascent, 1600, 'Font Ascent'
    option :font_descent, 200, 'Font Descent'

    option :templates, 'scss', 'Output templates'
    option :no_hash, true, 'Create hash for no cache policy'
    option :preprocessor_path, nil, 'Relative path from your compiled CSS to your output directory'

    def initialize(app, options_hash={}, &block)
      super

      return unless app.environment == :development

      options_hash = options.to_h

      compile = ->(config){
        ::Fontcustom::Base.new({
          :font_name => config[:font_name],
          :input => config[:source_dir],
          :output => {
            :fonts => config[:fonts_dir],
            :css => config[:css_dir]
          },
          :css_prefix => config[:css_prefix],
          :autowidth => config[:autowidth],
          :font_design_size => config[:font_design_size],
          :font_em => config[:font_em],
          :font_ascent => config[:font_ascent],
          :font_descent => config[:font_descent],
          :templates => config[:templates].split(/\s/),
          :no_hash => config[:no_hash],
          :preprocessor_path => config[:preprocessor_path]
        }).compile
      }

      app.ready do

        files.changed do |file|
          next if files.send(:ignored?, file)
          next if options_hash[:source_dir] != File.dirname(file)

          begin
            compile.call(options_hash)
          rescue => e
            logger.info e.message
          end
        end

        files.deleted do |file|
          next if files.send(:ignored?, file)
          next if options_hash[:source_dir] != File.dirname(file)

          begin
            compile.call(options_hash)
          rescue => e
            logger.info e.message
          end
        end

      end
    end
  end
end
