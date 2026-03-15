# ******************************************************************************
# VPN
# ******************************************************************************
# This file adds the migration VPC side: VPN gateway (where tunnel lands) and
# a Partner Interconnect VLAN attachment. The tunnel/interconnect would
# connect to the data center
# ******************************************************************************

# -----------------------------------------------------------------------------
# Cloud VPN gateway (migration VPC)
# -----------------------------------------------------------------------------
# The on-prem firewall/router establishes a tunnel to this
# gateway. We use HA VPN (high availability) with two interfaces.
# -----------------------------------------------------------------------------
resource "google_compute_ha_vpn_gateway" "migration_vpn_gateway" {
  name    = "migration-vpn-gateway"
  network = google_compute_network.migration_vpc.id
  region  = var.region
}

# External VPN gateway resource — represents the on-prem side for BGP/tunnel config.
resource "google_compute_external_vpn_gateway" "on_prem_gateway" {
  name            = "on-prem-vpn-gateway"
  redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
  description     = "Represents on-prem VPN endpoint (configure peer IP in production)"

  interface {
    id         = 0
    ip_address = var.on_prem_vpn_peer_ip # Set in tfvars for production; 203.0.113.1 is docs placeholder
  }
}

# Cloud Router for BGP (used by VPN and Interconnect)
resource "google_compute_router" "migration_router" {
  name    = "migration-router"
  region  = var.region
  network = google_compute_network.migration_vpc.id
  bgp {
    asn = 64514
  }
}

# -----------------------------------------------------------------------------
# Partner Interconnect — VLAN attachment (GCP side)
# -----------------------------------------------------------------------------
resource "google_compute_interconnect_attachment" "partner" {
  name    = "migration-interconnect-partner"
  region  = var.region
  router  = google_compute_router.migration_router.id
  type    = "PARTNER"
  edge_availability_domain = "AVAILABILITY_DOMAIN_1"
}
