module Carrierwave
  module Base64
    module Adapter
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def mount_base64_uploader(attribute, uploader_class, options = {})
        mount_uploader attribute, uploader_class, options
        options[:file_name] ||= proc { attribute }

        if options[:file_name].is_a?(String)
          warn(
            '[Deprecation warning] Setting `file_name` option to a string is '\
            'deprecated and will be removed in 3.0.0. If you want to keep the '\
            'existing behaviour, wrap the string in a Proc'
          )
        end

        define_method "#{attribute}=" do |data|
          return if data == send(attribute).to_s

          if respond_to?("#{attribute}_will_change!") && data.present?
            send "#{attribute}_will_change!"
          end

          return super(data) unless data.is_a?(String) &&
                                    data.strip.start_with?('data')

          filename = if options[:file_name].respond_to?(:call)
                       options[:file_name].call(self)
                     else
                       options[:file_name]
                     end.to_s

          super Carrierwave::Base64::Base64StringIO.new(data.strip, filename)
        end
        
        alias_method "#{attribute}_data_uri=", "#{attribute}="
      
        define_method "#{attribute}_data_uri" do 
          eval "#{attribute}.blank? ? '' : Base64.encode64(#{attribute}.read)"
        end
      
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/PerceivedComplexity
      end
    end
  end
end
