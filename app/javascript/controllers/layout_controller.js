import { Controller } from "@hotwired/stimulus"

// Controls the off-canvas sidebar on small screens.
export default class extends Controller {
  static targets = ["sidebar"]

  toggle() {
    this.element.classList.toggle("sidebar-open")
  }

  close() {
    this.element.classList.remove("sidebar-open")
  }
}
