module Yieldmanager
  class Report
    attr_accessor :headers, :data
    
    def initialize
      self.headers = []
      self.data = []
    end
    
    def pull token, report, xml
      report_token = request_report_token token, report, xml
      report_url = retrieve_report_url token, report, report_token
      retrieve_data report_url
    end

private
    
    def request_report_token token, report, xml
      report.requestViaXML(token,xml)
    end

    def retrieve_report_url token, report, report_token
      report_url = nil
      60.times do |secs| # Poll until report ready
        report_url = report.status(token,report_token)
        break if report_url != nil
        sleep(5)
      end
      report_url
    end
    
    def retrieve_data url
      doc = open(url) { |f| Hpricot(f) }
      (doc/"header column").each do |col|
        headers << col.inner_html
      end
      (doc/"row").each_with_index do |row,idx|
        row_hash = {}
        (row/"column").each do |col|
          row_hash[headers[idx]] = col.inner_html
        end
        data << row_hash
      end
    end
  end

end