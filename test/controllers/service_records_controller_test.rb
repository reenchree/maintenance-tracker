require "test_helper"

class ServiceRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @vehicle = vehicles(:civic)
    @service_record = service_records(:oil_change)
  end

  test "should get new" do
    get new_vehicle_service_record_url(@vehicle)
    assert_response :success
  end

  test "should create service record" do
    assert_difference("ServiceRecord.count") do
      post vehicle_service_records_url(@vehicle), params: {
        service_record: {
          service_type: "tire_rotation",
          description: "Tire rotation",
          performed_on: Date.current,
          mileage_at_service: 44000,
          cost_dollars_input: "45.00",
          shop_or_mechanic: "Local Shop"
        }
      }
    end

    record = ServiceRecord.last
    assert_equal 4500, record.cost_cents
    assert_redirected_to vehicle_url(@vehicle)
  end

  test "should show service record" do
    get vehicle_service_record_url(@vehicle, @service_record)
    assert_response :success
  end

  test "should get edit" do
    get edit_vehicle_service_record_url(@vehicle, @service_record)
    assert_response :success
  end

  test "should update service record" do
    patch vehicle_service_record_url(@vehicle, @service_record), params: {
      service_record: {
        description: "Updated oil change description",
        cost_dollars_input: "80.00"
      }
    }

    assert_redirected_to vehicle_url(@vehicle)
    @service_record.reload
    assert_equal "Updated oil change description", @service_record.description
    assert_equal 8000, @service_record.cost_cents
  end

  test "should destroy service record" do
    assert_difference("ServiceRecord.count", -1) do
      delete vehicle_service_record_url(@vehicle, @service_record)
    end

    assert_redirected_to vehicle_url(@vehicle)
  end

  test "should not create service record with invalid params" do
    assert_no_difference("ServiceRecord.count") do
      post vehicle_service_records_url(@vehicle), params: {
        service_record: {
          service_type: "oil_change",
          description: "",
          performed_on: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not update service record with invalid params" do
    patch vehicle_service_record_url(@vehicle, @service_record), params: {
      service_record: { description: "" }
    }

    assert_response :unprocessable_entity
    assert_equal "Synthetic oil change with filter", @service_record.reload.description
  end

  test "cost conversion handles empty input" do
    post vehicle_service_records_url(@vehicle), params: {
      service_record: {
        service_type: "oil_change",
        description: "Oil change",
        performed_on: Date.current,
        cost_dollars_input: ""
      }
    }

    assert_redirected_to vehicle_url(@vehicle)
    assert_nil ServiceRecord.last.cost_cents
  end

  test "cost conversion handles garbage input" do
    post vehicle_service_records_url(@vehicle), params: {
      service_record: {
        service_type: "oil_change",
        description: "Oil change",
        performed_on: Date.current,
        cost_dollars_input: "abc"
      }
    }

    assert_redirected_to vehicle_url(@vehicle)
    assert_nil ServiceRecord.last.cost_cents
  end

  test "service record show is scoped to vehicle" do
    other_vehicle = vehicles(:sportster)
    get vehicle_service_record_url(other_vehicle, @service_record)
    assert_response :not_found
  end

  test "service record edit is scoped to vehicle" do
    other_vehicle = vehicles(:sportster)
    get edit_vehicle_service_record_url(other_vehicle, @service_record)
    assert_response :not_found
  end

  test "service record update is scoped to vehicle" do
    other_vehicle = vehicles(:sportster)
    patch vehicle_service_record_url(other_vehicle, @service_record), params: {
      service_record: { description: "Hacked" }
    }
    assert_response :not_found
    assert_equal "Synthetic oil change with filter", @service_record.reload.description
  end

  test "service record destroy is scoped to vehicle" do
    other_vehicle = vehicles(:sportster)
    assert_no_difference("ServiceRecord.count") do
      delete vehicle_service_record_url(other_vehicle, @service_record)
    end
    assert_response :not_found
  end
end
