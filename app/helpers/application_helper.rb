module ApplicationHelper
  STATUS_TONES = {
    "pending" => :yellow,
    "in_progress" => :blue,
    "confirmed" => :green,
    "completed" => :green,
    "cancelled" => :gray,
    "paid" => :green,
    "overdue" => :red,
    "available" => :green,
    "occupied" => :blue,
    "maintenance" => :yellow,
    "low" => :gray,
    "medium" => :blue,
    "high" => :yellow,
    "urgent" => :red,
    "critical" => :red,
    "received" => :yellow,
    "notified" => :blue,
    "picked_up" => :green,
    "returned" => :gray,
    "open" => :yellow,
    "acknowledged" => :blue,
    "resolved" => :green,
    "dismissed" => :gray,
    "fined" => :red,
    "closed" => :gray
  }.freeze

  def badge(text, tone = :gray)
    content_tag(:span, text, class: "badge badge-#{tone}")
  end

  def status_badge(record)
    text, tone = case record
                 when MaintenanceRequest
                   [record.status_label, STATUS_TONES[record.status]]
                 when Payment
                   [record.status_label, record.overdue? && !record.paid? ? :red : STATUS_TONES[record.status]]
                 when Reservation
                   [record.status.titleize, STATUS_TONES[record.status]]
                 when Visitor
                   tone = if record.checked_out_at.present?
                            :gray
                          elsif record.checked_in_at.present?
                            :green
                          elsif record.approved?
                            :blue
                          else
                            :yellow
                          end
                   [record.status_label, tone]
                  when Unit
                    [record.status.titleize, STATUS_TONES[record.status]]
                  when Notice
                    [record.priority_label, STATUS_TONES[record.priority]]
                  when Package
                    [record.status_label, STATUS_TONES[record.status]]
                  when Violation
                    [record.status_label, STATUS_TONES[record.status]]
                  when Poll
                    [record.status.titleize, STATUS_TONES[record.status]]
                 else
                   [record.to_s, :gray]
                 end

    badge(text, tone || :gray)
  end

  def priority_badge(priority)
    badge(priority.to_s.capitalize, STATUS_TONES[priority] || :gray)
  end

  def money(amount)
    number_to_currency(amount || 0)
  end

  def nav_active?(controllers)
    Array(controllers).include?(controller_name)
  end

  def nav_link_class(controllers, extra: nil)
    classes = ["nav-link"]
    classes << "active" if nav_active?(controllers)
    classes << extra if extra
    classes.join(" ")
  end

  def page_title(title, subtitle: nil, &block)
    content_for(:title, title)
    render "shared/page_header", title: title, subtitle: subtitle, actions: (capture(&block) if block)
  end

  def initials_for(user)
    user&.initials.presence || "?"
  end
end
