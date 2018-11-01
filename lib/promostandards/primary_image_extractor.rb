module PromoStandards
  class PrimaryImageExtractor
    PRIMARY_IMAGE_PRECEDENCE = ['1006', ['1007', '1001', '2001'], ['1007', '1001'], '1007', ['1001', '2001'], '1001', '1003']

    def extract(media_content_response)
      if media_content_response.is_a? Array
        primary_media_content = nil

        PRIMARY_IMAGE_PRECEDENCE.find do |image_precendence_number|
          primary_media_content = media_content_response.find do |media|
            if media[:class_type_array]
              class_type_array = media[:class_type_array][:class_type]

              class_type_ids = []

              if class_type_array.is_a?(Hash)
                class_type_ids = [class_type_array[:class_type_id]]
              elsif class_type_array.is_a?(Array)
                class_type_ids = class_type_array.map { |item| item[:class_type_id] }
              end

              if image_precendence_number.is_a?(Array)
                (class_type_ids & image_precendence_number).any?
              else
                class_type_ids.include?(image_precendence_number)
              end
            end
          end
        end
        primary_media_content || media_content_response.first
      else
        media_content_response
      end

    end
  end
end