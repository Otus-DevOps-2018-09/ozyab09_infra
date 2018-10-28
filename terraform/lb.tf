#Создадим правило переслки
resource "google_compute_forwarding_rule" "default" {
  name                  = "reddit-app-forwarding-rule"
  target                = "${google_compute_target_pool.default.self_link}"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "9292"
}

#Балансировщик
resource "google_compute_target_pool" "default" {
  name = "reddit-pool"
  instances = ["${google_compute_instance.app.*.self_link}"]
  health_checks = [
    "${google_compute_http_health_check.default.name}",
  ]
}

#Здоровье инстансов
resource "google_compute_http_health_check" "default" {
  name               = "default"
  request_path       = "/"
  port               = 9292
  check_interval_sec = 5
  timeout_sec        = 2
}