import { Controller } from "@hotwired/stimulus"

// Shows the relevant unit-assignment fields based on the selected user role.
export default class extends Controller {
  static targets = ["select", "resident", "owner", "residentHint", "ownerHint", "assignment"]

  connect() {
    this.update()
  }

  change() {
    this.update()
  }

  update() {
    const role = this.selectTarget.value
    this.toggle(this.residentTargets, role === "resident")
    this.toggle(this.ownerTargets, role === "owner")
    this.toggle(this.residentHintTargets, role === "resident")
    this.toggle(this.ownerHintTargets, role === "owner")

    if (this.hasAssignmentTarget) {
      const staff = role === "admin" || role === "manager"
      this.assignmentTarget.style.display = staff ? "none" : ""
    }
  }

  toggle(elements, show) {
    elements.forEach((el) => {
      el.style.display = show ? "" : "none"
    })
  }
}
