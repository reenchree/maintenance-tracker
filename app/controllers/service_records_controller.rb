class ServiceRecordsController < ApplicationController
  before_action :set_vehicle
  before_action :set_service_record, only: %i[ show edit update destroy ]

  def show
  end

  def new
    @service_record = @vehicle.service_records.build
  end

  def edit
  end

  def create
    @service_record = @vehicle.service_records.build(service_record_params)

    if @service_record.save
      redirect_to @vehicle, notice: "Service record was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @service_record.update(service_record_params)
      redirect_to @vehicle, notice: "Service record was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service_record.destroy!
    redirect_to @vehicle, notice: "Service record was successfully deleted.", status: :see_other
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find(params.expect(:vehicle_id))
  end

  def set_service_record
    @service_record = @vehicle.service_records.find(params.expect(:id))
  end

  def service_record_params
    permitted = params.expect(service_record: [ :service_type, :description, :performed_on, :mileage_at_service, :shop_or_mechanic, :notes ])

    cost_input = params.dig(:service_record, :cost_dollars_input)
    if cost_input.present?
      dollars = BigDecimal(cost_input)
      permitted[:cost_cents] = (dollars * 100).to_i
    else
      permitted[:cost_cents] = nil
    end

    permitted
  rescue ArgumentError
    permitted[:cost_cents] = nil
    permitted
  end
end
