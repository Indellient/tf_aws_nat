data "aws_subnet" "first" {
  id = "${var.public_subnet_ids[0]}"
}

data "aws_vpc" "vpc" {
  id = "${data.aws_subnet.first.vpc_id}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/nat-user-data.conf.tmpl")}"
  count    = "${var.instance_count}"

  vars {
    name              = "${var.name}"
    mysubnet          = "${element(var.private_subnet_ids, count.index)}"
    vpc_cidr          = "${data.aws_vpc.vpc.cidr_block}"
    region            = "${var.aws_region}"
    awsnycast_deb_url = "${var.awsnycast_deb_url}"
    identifier        = "${var.route_table_identifier}"
  }
}

resource "null_resource" "ping_bastion" {
  provisioner "local-exec" {
    command = "if [ -n ${var.ssh_bastion_host} ]; then until ssh -i ${var.aws_key_location} -o StrictHostKeyChecking=no -q ${var.ssh_bastion_user}@${var.ssh_bastion_host} exit; do sleep 2; done; fi"
  }
}

resource "aws_instance" "nat" {
  count                  = "${var.instance_count}"
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  source_dest_check      = false
  iam_instance_profile   = "${aws_iam_instance_profile.nat_profile.id}"
  key_name               = "${var.aws_key_name}"
  subnet_id              = "${element(var.public_subnet_ids, count.index)}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  tags                   = "${merge(var.tags, map("Name", format("%s-nat%d", var.name, count.index+1)))}"
  user_data              = "${element(data.template_file.user_data.*.rendered, count.index)}"
  depends_on             = ["null_resource.ping_bastion"]

  provisioner "remote-exec" {
    inline = [
      "while sudo pkill -0 cloud-init; do sleep 2; done",
    ]

    connection {
      user = "${var.ssh_user}"

      # If we are using a bastion host ssh in via the private IP
      # If we set this to an empty string we get the default behaviour.
      host = "${var.ssh_bastion_host != "" ? self.private_ip : ""}"

      # host = "${self.public_ip}"
      private_key  = "${file("${var.aws_key_location}")}"
      bastion_host = "${var.ssh_bastion_host}"
      bastion_user = "${var.ssh_bastion_user}"
    }
  }
}
