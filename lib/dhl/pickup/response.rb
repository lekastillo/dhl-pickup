class Dhl::Pickup::Response
  include Dhl::Pickup::Helper

  attr_reader :raw_xml, :parsed_xml, :errors
  attr_reader :currency_code, :currency_role_type_code, :weight_charge, :total_amount, :total_tax_amount, :weight_charge_tax

  CURRENCY_ROLE_TYPE_CODES = %w[ BILLC PULCL BASEC INVCU ]
  DEFAULT_CURRENCY_ROLE_TYPE_CODE = 'BILLC'

  def initialize(xml="")
    @raw_xml = xml
    @errors = []

    begin
      @parsed_xml = MultiXml.parse(xml)
    rescue MultiXml::ParseError => e
      @errors << e
      return self
    end

    if response_indicates_error?
      @error = case response_error_condition_code.to_s
      when "100"
        Dhl::Pickup::Upstream::ValidationFailureError.new(response_error_condition_data)
      when "111"
        Dhl::Pickup::Upstream::ParsinDataError.new(response_error_condition_data)
      else
        Dhl::Pickup::Upstream::UnknownError.new(response_error_condition_data)
      end
    else
      puts 'all is good'
    end
  end

  def error?
    !@errors.empty?
  end


protected

  def response_indicates_error?
    @parsed_xml.keys.include?('ErrorResponse')
  end

  def response_error_status_condition
    @response_error_status_condition ||= @parsed_xml['ErrorResponse']['Response']['Status']['Condition']
  end

  def response_error_condition_code
    @response_error_condition_code ||= response_error_status_condition['ConditionCode']
  end

  def response_error_condition_data
    @response_error_condition_data ||= response_error_status_condition['ConditionData']
  end

  def condition_indicates_error?
    result = false
    if @parsed_xml["DCTResponse"]["GetQuoteResponse"] && @parsed_xml["DCTResponse"]["GetQuoteResponse"]["Note"]
      note = @parsed_xml["DCTResponse"]["GetQuoteResponse"]["Note"]

      if note.is_a?(Array)
        result = note.map{|condition| condition.is_a?(Hash)}.include?(true)
      else
        result = note["Condition"].is_a?(Hash) 
      end
    end

    result
  end

  def create_condition_errors
    notes = []
    notes << @parsed_xml["DCTResponse"]["GetQuoteResponse"]["Note"]
    notes.flatten!

    notes.map do |note|
      error_code = note["Condition"]["ConditionCode"]
      error_message = note["Condition"]["ConditionData"].strip
      Dhl::Pickup::Upstream::ConditionError.new(error_code, error_message)
    end
  end

  #def condition_error_code
    #@parsed_xml["DCTResponse"]["GetQuoteResponse"]["Note"]["Condition"]["ConditionCode"]
  #end

  #def condition_error_message
    #@parsed_xml["DCTResponse"]["GetQuoteResponse"]["Note"]["Condition"]["ConditionData"].strip
  #end


end