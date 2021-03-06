module PromoStandards
  class PrimaryImageExtractor
    PRIMARY_IMAGE_PRECEDENCE = [['1001','2001','1006'], ['1001','2000','1006'], ['1001','2001','1007'],
                                ['1001','2000','1007'], ['1001','2001','1014'], ['1001','2000','1014'],
                                ['2001','1006'], ['2000','1006'], ['2001','1007'], ['2000','1007'],
                                ['2001','1014'], ['2000','1014'], ['1001','2001'], ['1001','2000'],
                                ['1003', '2001'], ['1006'], ['2001'], ['2000']]

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

              (image_precendence_number - class_type_ids).empty?
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
