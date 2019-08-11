require 'rubygems'
require 'httparty'
require 'erb'
require 'set'

class Dhl::Pickup::Request
  attr_reader :site_id, :password, :region, :pickup_action, :requestor, :place, :pickup, :pickup_contact, :shipment_details
  attr_accessor :language, :reference_id, :confirmation_number, :requestor_name, :country_code, :reason, :pickup_date, :cancel_time

  URLS = {
    :production => 'https://xmlpi-ea.dhl.com/XMLShippingServlet',
    :test       => 'https://xmlpitest-ea.dhl.com/XMLShippingServlet'
  }

  def initialize(options = {})
    @test_mode = !!options[:test_mode] || Dhl::Pickup.test_mode?

    @site_id = options[:site_id] || Dhl::Pickup.site_id
    @password = options[:password] || Dhl::Pickup.password

    [ :site_id, :password ].each do |req|
      unless instance_variable_get("@#{req}").to_s.size > 0
        raise Dhl::Pickup::OptionsError, ":#{req} is a required option"
      end
    end

    @pickup_action = 'request'
    @region = 'AM'
  end

  def set_region(region)
    @region = region
  end

  def test_mode?
    !!@test_mode
  end

  def test_mode!
    @test_mode = true
  end

  def production_mode!
    @test_mode = false
  end

  def pickup_action_request!
    @pickup_action = 'request'
  end
  
  def pickup_action_cancel!
    @pickup_action = 'cancel'
  end

  def pickup_action_request?
  !!@pickup_action and @pickup_action=='request'
  end

  def pickup_action_cancel?
  !!@pickup_action and @pickup_action=='cancel'
  end
  
  def set_requestor(requestor_params = {})
    @requestor = {
      :account_type => requestor_params[:account_type],
      :account_number => requestor_params[:account_number],
      :requestor_contact_person_name => requestor_params[:requestor_contact_person_name],
      :requestor_contact_phone => requestor_params[:requestor_contact_phone],
      :company_name => requestor_params[:company_name],
      :country_code => requestor_params[:country_code],
      :city => requestor_params[:city],
      :address1 => requestor_params[:address1],
      :address2 => requestor_params[:address2],
      :address3 => requestor_params[:address3]
    }
  end
  alias_method :set_requestor!, :set_requestor
  
  def set_place(place_params = {})
    @place = {
      :location_type => place_params[:location_type],
      :company_name => place_params[:company_name],
      :package_location => place_params[:package_location],
      :country_code => place_params[:country_code],
      :city => place_params[:city],
      :address1 => place_params[:address1],
      :address2 => place_params[:address2],
      :address3 => place_params[:address3],
      :postal_code => place_params[:postal_code],
      :suburb => place_params[:suburb],
    }
  end
  alias_method :set_place!, :set_place
  
  def set_pickup(pickup_params = {})
    @pickup = {
      :pickup_date => pickup_params[:pickup_date],
      :pickup_type_code => pickup_params[:pickup_type_code],
      :ready_by_time => pickup_params[:ready_by_time],
      :close_time => pickup_params[:close_time],
      :after_hours_closing_time => pickup_params[:after_hours_closing_time],
      :after_hours_location => pickup_params[:after_hours_location],
      :pieces => pickup_params[:pieces],
      :remote_pickup_flag => pickup_params[:remote_pickup_flag],
      :weight => pickup_params[:weight],
      :weight_unit => pickup_params[:weight_unit],
      :special_instructions => pickup_params[:special_instructions],
      :remarks => pickup_params[:remarks]
    }
  end
  alias_method :set_pickup!, :set_pickup

  def set_shipment_details(shipment_details_params = {})
    @shipment_details = {
      :account_type => shipment_details_params[:account_type],
      :account_number => shipment_details_params[:account_number],
      :bill_to_account_number => shipment_details_params[:bill_to_account_number],
      :awb_number => shipment_details_params[:awb_number],
      :numberof_pieces => shipment_details_params[:numberof_pieces],
      :weight => shipment_details_params[:weight],
      :weight_unit => shipment_details_params[:weight_unit],
      :global_product_code => shipment_details_params[:global_product_code],
      :local_product_code => shipment_details_params[:local_product_code],
      :door_to => shipment_details_params[:door_to],
      :special_instructions => shipment_details_params[:special_instructions],
      :remarks => shipment_details_params[:remarks]
    }
  end
  alias_method :set_shipment_details!, :set_shipment_details

  def set_pickup_contact(pickup_contact_params = {})
    @pickup_contact = {
      :pickup_contact_person_name => pickup_contact_params[:pickup_contact_person_name],
      :pickup_contact_phone => pickup_contact_params[:pickup_contact_phone],
    }
  end
  alias_method :set_pickup_contact!, :set_pickup_contact

  def dimensions_unit
    @dimensions_unit ||= Dhl::Pickup.dimensions_unit
  end

  def weight_unit
    @weight_unit ||= Dhl::Pickup.weight_unit
  end

  def metric_measurements!
    @weight_unit = Dhl::Pickup::WEIGHT_UNIT_CODES[:kilograms]
    @dimensions_unit = Dhl::Pickup::DIMENSIONS_UNIT_CODES[:centimeters]
  end

  def us_measurements!
    @weight_unit = Dhl::Pickup::WEIGHT_UNIT_CODES[:pounds]
    @dimensions_unit = Dhl::Pickup::DIMENSIONS_UNIT_CODES[:inches]
  end

  def centimeters!
    deprication_notice(:centimeters!, :metric)
    metric_measurements!
  end
  alias :centimetres! :centimeters!

  def inches!
    deprication_notice(:inches!, :us)
    us_measurements!
  end

  def metric_measurements?
    centimeters? && kilograms?
  end

  def us_measurements?
    pounds? && inches?
  end

  def centimeters?
    dimensions_unit == Dhl::Pickup::DIMENSIONS_UNIT_CODES[:centimeters]
  end
  alias :centimetres? :centimeters?

  def inches?
    dimensions_unit == Dhl::Pickup::DIMENSIONS_UNIT_CODES[:inches]
  end

  def kilograms!
    deprication_notice(:kilograms!, :metric)
    metric_measurements!
  end
  alias :kilogrammes! :kilograms!

  def pounds!
    deprication_notice(:pounds!, :us)
    us_measurements!
  end

  def pounds?
    weight_unit == Dhl::Pickup::WEIGHT_UNIT_CODES[:pounds]
  end

  def kilograms?
    weight_unit == Dhl::Pickup::WEIGHT_UNIT_CODES[:kilograms]
  end
  alias :kilogrammes? :kilograms?

  def to_xml
    # validate!
    @to_xml = ERB.new(File.new(xml_template_path).read, nil,'%<>-').result(binding)
  end

  def post
    response = HTTParty.post(servlet_url,
      :body => to_xml,
      :headers => { 'Content-Type' => 'application/xml' }
    ).response

    return Dhl::Pickup::Response.new(response.body)
  rescue Exception => e
    request_xml = if @to_xml.to_s.size>0
      @to_xml
    else
      '<not generated at time of error>'
    end

    response_body = if (response && response.body && response.body.to_s.size > 0)
      response.body
    else
      '<not received at time of error>'
    end

    log_level = if e.respond_to?(:log_level)
      e.log_level
    else
      :critical
    end

    log_request_and_response_xml(log_level, e, request_xml, response_body )
    raise e
  end


protected

  def servlet_url
    test_mode? ? URLS[:test] : URLS[:production]
  end

  def validate!
    raise Dhl::Pickup::OptionsError, "#Data is not set" unless !(@pickup_action)
    # validate_pieces!
  end

  def xml_template_path
    spec = Gem::Specification.find_by_name("dhl-shipment")
    gem_root = spec.gem_dir
    gem_root + "/tpl/request.xml.erb"
  end

private

  def deprication_notice(meth, m)
    messages = {
      :metric => "Method replaced by Dhl::Pickup::Request#metic_measurements!(). I am now setting your measurements to metric",
      :us     => "Method replaced by Dhl::Pickup::Request#us_measurements!(). I am now setting your measurements to US customary",
    }
    puts "!!!! Method \"##{meth}()\" is depricated. #{messages[m.to_sym]}."
  end

  def log_request_and_response_xml(level, exception, request_xml, response_xml)
    log_exception(exception, level)
    log_request_xml(request_xml, level)
    log_response_xml(response_xml, level)
  end

  def log_exception(exception, level)
    log("Exception: #{exception}", level)
  end

  def log_request_xml(xml, level)
    log("Request XML: #{xml}", level)
  end

  def log_response_xml(xml, level)
    log("Response XML: #{xml}", level)
  end

  def log(msg, level)
    Dhl::Pickup.log(msg, level)
  end

end
