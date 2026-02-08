import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["vin", "make", "model", "year", "trim", "vehicleType", "button", "error"]
  static values = { url: String }

  async decode() {
    const vin = this.vinTarget.value.trim()

    if (vin.length !== 17) {
      this.showError("VIN must be 17 characters")
      return
    }

    this.clearError()
    this.setLoading(true)

    try {
      const response = await fetch(`${this.urlValue}?vin=${encodeURIComponent(vin)}`)
      const data = await response.json()

      if (data.error) {
        this.showError(data.error)
        return
      }

      this.fillFields(data)
    } catch {
      this.showError("Failed to look up VIN — please try again")
    } finally {
      this.setLoading(false)
    }
  }

  fillFields(data) {
    if (data.make != null) this.makeTarget.value = data.make
    if (data.model != null) this.modelTarget.value = data.model
    if (data.year != null) this.yearTarget.value = data.year
    if (data.trim != null) this.trimTarget.value = data.trim
    if (data.vehicle_type != null) this.vehicleTypeTarget.value = data.vehicle_type
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.hidden = false
  }

  clearError() {
    this.errorTarget.textContent = ""
    this.errorTarget.hidden = true
  }

  setLoading(loading) {
    this.buttonTarget.disabled = loading
    this.buttonTarget.textContent = loading ? "Looking up…" : "Decode VIN"
  }
}
