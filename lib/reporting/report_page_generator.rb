class ReportPageGenerator
  attr_accessor :report

  def generate(report_type = :normal)
    report_result = {:header_columns => {:value => report.header_columns, :presenter => report.header_column_presenter},
              :first_column => {:title => report.first_column_title}
             }

    send('generate_' + report_type.to_s)
  end

  def generate_normal

  end

  def generate_sectioned
    report_result[:body_sections] = []
    report.sections.each do |section|
      dataset = report.dataset(:section => section)
      dataset.each do |data|
        body_row =  {
            :first_column => {:value => report.first_column_value(data)},
            :values => []
          }
        report_result.header_columns.each do |column|
          body_row[:values] << report.data_for(column, data)
        end
        report_result[:body_rows] << body_row
      end
    end
  end

end