module Mongoid
  module Extensions
    module String
      def __convert_to_date__(str, format=:default)
        if str.include? '/'
          ::Date.strptime(str, I18n.translate("date.formats.#{format}")).strftime('%Y-%m-%d %H:%M:%S')
        else
          str
        end
      end

      def __mongoize_time__
        ::Time.parse(__convert_to_date__(self))
        ::Time.configured.parse(__convert_to_date__(self))
      end
    end
  end
end