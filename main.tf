/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "random_string" "name_suffix" {
  length = 6
  upper = false
  special = false
}

locals {
  # intermediate locals
  default_name = "cloud-nat-${random_string.name_suffix.result}"
  nat_ips_length = "${length(var.nat_ips)}"
  default_nat_ip_allocate_option = "${local.nat_ips_length > 0 ? "MANUAL_ONLY" : "AUTO_ONLY" }"

  # locals for google_compute_router_nat
  nat_ip_allocate_option = "${var.nat_ip_allocate_option ? var.nat_ip_allocate_option : local.default_nat_ip_allocate_option}"
  name = "${var.name != "" ? var.name : local.default_name}"
  source_subnetwork_ip_ranges_to_nat = "${length(var.subnetworks) > 0 ? "LIST_OF_SUBNETWORKS" : var.source_subnetwork_ip_ranges_to_nat}"
}

resource "google_compute_router_nat" "main" {
  project = "${var.project_id}"
  region = "${var.region}"

  name = "${local.name}"
  router = "${var.router}"

  nat_ip_allocate_option = "${local.nat_ip_allocate_option}"
  nat_ips = ["${var.nat_ips}"]
  source_subnetwork_ip_ranges_to_nat = "${local.source_subnetwork_ip_ranges_to_nat}"

  # Error: module.cloud-nat.google_compute_router_nat.main: subnetwork: should be a list
  subnetwork = "${var.subnetworks}"

  # Error: module.cloud-nat.google_compute_router_nat.main: "subnetwork.0.name": required field is not set
  # subnetwork = ["${var.subnetworks}"]

  min_ports_per_vm = "${var.min_ports_per_vm}"
  udp_idle_timeout_sec = "${var.udp_idle_timeout_sec}"
  icmp_idle_timeout_sec = "${var.icmp_idle_timeout_sec}"
  tcp_established_idle_timeout_sec = "${var.tcp_established_idle_timeout_sec}"
  tcp_transitory_idle_timeout_sec = "${var.tcp_transitory_idle_timeout_sec}"
}
