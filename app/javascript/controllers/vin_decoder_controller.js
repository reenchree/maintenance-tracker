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
    // Order matters: vehicleType first (triggers makes fetch), then year,
    // then make (triggers models fetch with year already set)
    const fields = [
      [data.vehicle_type, this.vehicleTypeTarget],
      [data.year, this.yearTarget],
      [data.make, this.makeTarget],
      [data.model, this.modelTarget],
      [data.trim, this.trimTarget],
    ]
    for (const [value, target] of fields) {
      if (value != null) {
        this.ensureOption(target, value)
        target.value = value
        target.dispatchEvent(new Event("change", { bubbles: true }))
      }
    }
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.hidden = false
  }

  clearError() {
    this.errorTarget.textContent = ""
    this.errorTarget.hidden = true
  }

  ensureOption(target, value) {
    if (target.tagName !== "SELECT") return
    const str = String(value)
    const exists = Array.from(target.options).some(o => o.value === str)
    if (!exists) {
      const option = document.createElement("option")
      option.value = str
      option.textContent = str
      target.appendChild(option)
    }
  }

  setLoading(loading) {
    this.buttonTarget.disabled = loading
    this.buttonTarget.textContent = loading ? "Looking up…" : "Decode VIN"
  }
}
