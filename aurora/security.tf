resource aws_security_group aurora_security_group {
  vpc_id = data.aws_vpc.deployable_vpc.id
  name = "${var.application_name}-${var.environment}-sg"

  ingress {
    from_port = var.aurora_port
    protocol  = "tcp"
    to_port   = var.aurora_port
  }
}

  resource aws_security_group_rule aurora_egress {
    from_port         = var.aurora_port
    protocol          = "TCP"
    security_group_id = aws_security_group.aurora_security_group.id
    to_port           = var.aurora_port
    type              = "egress"
    cidr_blocks = [data.aws_vpc.deployable_vpc.cidr_block]
  }

  resource aws_security_group_rule aurora_ingress {
    from_port         = var.aurora_port
    protocol          = "TCP"
    security_group_id = aws_security_group.aurora_security_group.id
    to_port           = var.aurora_port
    type              = "ingress"
    cidr_blocks = [data.aws_vpc.deployable_vpc.cidr_block]
  }

#  resource aws_security_group_rule secretsmanager_ingress {
#    from_port = 443
#    protocol = "TCP"
#    security_group_id = aws_security_group.aurora_security_group.id
#    to_port = 443
#    type = "ingress"
#    cidr_blocks = [data.aws_vpc.deployable_vpc.cidr_block]
#  }
#
#  resource aws_security_group_rule secretsmanager_egress {
#    from_port = 443
#    protocol = "TCP"
#    security_group_id = aws_security_group.aurora_security_group.id
#    to_port = 443
#    type = "egress"
#    cidr_blocks = [data.aws_vpc.deployable_vpc.cidr_block]
#  }

  resource aws_security_group_rule sg_recursive_ingress {
    from_port         = 0
    protocol          = "TCP"
    security_group_id = aws_security_group.aurora_security_group.id
    to_port           = 65535
    type              = "ingress"
    source_security_group_id = aws_security_group.aurora_security_group.id
  }

  resource aws_security_group_rule sg_recursive_egress {
    from_port         = 0
    protocol          = "TCP"
    security_group_id = aws_security_group.aurora_security_group.id
    to_port           = 65535
    type              = "egress"
    source_security_group_id = aws_security_group.aurora_security_group.id
  }

// Destination eni-0fb0489e966b91aca
// Source aws ec2 describe-network-interfaces --filters Name=vpc-id,Values=vpc-0a8a1643014acba3d Name=interface-type,Values=lambda Name=subnet-id,Values=subnet-02eb30f34ab50858b
