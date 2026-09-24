import { Controller } from "@hotwired/stimulus"

// Auto-dismiss flash messages and allow manual closing.
export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.itemTargets.forEach((item) => {
      const timer = setTimeout(() => this.hide(item), 6000)
      item.addEventListener("mouseenter", () => clearTimeout(timer))
      item._flashTimer = timer
    })
  }

  dismiss(event) {
    this.hide(event.currentTarget.closest("[data-flash-target='item']"))
  }

  hide(item) {
    if (!item) return
    clearTimeout(item._flashTimer)
    item.style.transition = "opacity 0.25s ease, transform 0.25s ease"
    item.style.opacity = "0"
    item.style.transform = "translateY(-6px)"
    setTimeout(() => item.remove(), 250)
  }
}
