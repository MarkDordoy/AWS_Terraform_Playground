data "aws_caller_identity" "london_peer" {
  provider = "aws.london"
}

#Requesters side of the connection (ireland)
resource "aws_vpc_peering_connection" "eu-west-1_requester_peer" {
    vpc_id         =  aws_vpc.eu_west1_vpc.id
    peer_vpc_id    = aws_vpc.eu_west2_vpc.id
    peer_owner_id  = data.aws_caller_identity.london_peer.account_id
    peer_region    = "eu-west-2"
    auto_accept    = false

    tags = {
        Side = "Requester"
        Name = "Ireland_to_London"
    }
}

#Accepter side of the connection (London)
resource "aws_vpc_peering_connection_accepter" "eu-west-2_accepter_peer" {
    provider                  = aws.london
    vpc_peering_connection_id = aws_vpc_peering_connection.eu-west-1_requester_peer.id
    auto_accept               = true

    tags = {
        Side = "Accepter"
        Name = "London_to_Ireland"
  }
}

resource "aws_route" "eu-west-1-to-eu-west-2-private-route" {
    route_table_id              = aws_route_table.private_route_table.id
    destination_cidr_block      = "10.1.0.0/16"
    vpc_peering_connection_id   = aws_vpc_peering_connection.eu-west-1_requester_peer.id
}

resource "aws_route" "eu-west-2-to-eu-west-1-private-route" {
    provider                    = aws.london
    route_table_id              = aws_route_table.private_route_table_eu_west2.id
    destination_cidr_block      = "10.0.0.0/16"
    vpc_peering_connection_id   = aws_vpc_peering_connection_accepter.eu-west-2_accepter_peer.id
}