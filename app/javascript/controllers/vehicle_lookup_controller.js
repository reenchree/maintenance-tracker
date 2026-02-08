import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["vehicleType", "year", "make", "model", "makeList", "modelList"]
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
    this.clearDatalist(this.makeListTarget)
    this.clearDatalist(this.modelListTarget)

    if (!vehicleType) return

    try {
      const url = `${this.makesUrlValue}?vehicle_type=${encodeURIComponent(vehicleType)}`
      const response = await fetch(url)
      const makes = await response.json()
      this.populateDatalist(this.makeListTarget, makes)
    } catch {
      // Silent degradation — input still works as free-text
    }
  }

  async fetchModels() {
    const make = this.makeTarget.value.trim()
    const year = this.yearTarget.value
    this.clearDatalist(this.modelListTarget)

    if (!make || !year) return

    try {
      const url = `${this.modelsUrlValue}?make=${encodeURIComponent(make)}&year=${encodeURIComponent(year)}`
      const response = await fetch(url)
      const models = await response.json()
      this.populateDatalist(this.modelListTarget, models)
    } catch {
      // Silent degradation — input still works as free-text
    }
  }

  populateDatalist(datalist, items) {
    for (const item of items) {
      const option = document.createElement("option")
      option.value = item
      datalist.appendChild(option)
    }
  }

  clearDatalist(datalist) {
    datalist.innerHTML = ""
  }
}
