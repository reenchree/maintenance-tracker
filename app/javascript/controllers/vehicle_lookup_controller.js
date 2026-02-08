import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["vehicleType", "year", "make", "model"]
  static values = { makesUrl: String, modelsUrl: String }

  connect() {
    if (this.vehicleTypeTarget.value) {
      this.fetchMakes()
    }
    if (this.makeTarget.value && this.yearTarget.value) {
      this.fetchModels()
    }
  }

  async fetchMakes() {
    const vehicleType = this.vehicleTypeTarget.value
    this.populateSelect(this.makeTarget, [])
    this.populateSelect(this.modelTarget, [])

    if (!vehicleType) return

    this.setLoading(this.makeTarget, true)

    try {
      const url = `${this.makesUrlValue}?vehicle_type=${encodeURIComponent(vehicleType)}`
      const response = await fetch(url)
      const makes = await response.json()
      this.populateSelect(this.makeTarget, makes)
    } catch {
      // Silent degradation — select keeps current value if any
    } finally {
      this.setLoading(this.makeTarget, false)
    }
  }

  async fetchModels() {
    const make = this.makeTarget.value
    const year = this.yearTarget.value
    this.populateSelect(this.modelTarget, [])

    if (!make || !year) return

    this.setLoading(this.modelTarget, true)

    try {
      const url = `${this.modelsUrlValue}?make=${encodeURIComponent(make)}&year=${encodeURIComponent(year)}`
      const response = await fetch(url)
      const models = await response.json()
      this.populateSelect(this.modelTarget, models)
    } catch {
      // Silent degradation — select keeps current value if any
    } finally {
      this.setLoading(this.modelTarget, false)
    }
  }

  setLoading(select, loading) {
    if (loading) {
      select.disabled = true
      const prompt = select.querySelector('option[value=""]')
      if (prompt) {
        prompt.dataset.originalText = prompt.textContent
        prompt.textContent = "Loading…"
      }
    } else {
      select.disabled = false
      const prompt = select.querySelector('option[value=""]')
      if (prompt?.dataset.originalText) {
        prompt.textContent = prompt.dataset.originalText
        delete prompt.dataset.originalText
      }
    }
  }

  populateSelect(select, items) {
    const currentValue = select.value
    const promptOption = select.querySelector('option[value=""]')
    select.innerHTML = ""

    if (promptOption) select.appendChild(promptOption)

    // Preserve current value even if not in fetched items
    if (currentValue && !items.includes(currentValue)) {
      items = [currentValue, ...items]
    }

    for (const item of items) {
      const option = document.createElement("option")
      option.value = item
      option.textContent = item
      select.appendChild(option)
    }

    if (currentValue) select.value = currentValue
  }
}
