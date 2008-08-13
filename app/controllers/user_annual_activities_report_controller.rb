require 'user_report_pdf_transformer'
class  UserAnnualActivitiesReportController < UserDocumentController
  helper :textile
  include Stackcontroller
  def initialize
    @document_name = 'Informe anual de actividades'
    super
  end

  def preview
    unless @document_title.nil?
     @report = UserReport.new(session[:user])
     @data =  @report.as_array
     render :action => 'preview'
    else
     redirect_to :action => 'list'
    end
  end

  def preview_pdf
    @report = UserReport.new(session[:user])
    @pdf = UserReportPdfTransformer.new(@document_title)
    @pdf.report_code report_code
    @pdf.add_data @report.as_array
    send_data @pdf.render, :type => "application/pdf", :filename => filename
  end

  def send_document
    @report = UserReport.new(session[:user])
    @pdf = UserReportPdfTransformer.new(@document_title)
    @pdf.add_received_stamp
    @pdf.report_code report_code
    @pdf.add_data @report.as_array
    @file = @pdf.render
    @filename = filename
    super
  end
end
