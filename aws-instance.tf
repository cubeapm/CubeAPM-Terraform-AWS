// ec2 instance for CubeAPM.
resource "aws_instance" "cubeapm_instance" {
  ami                    = var.aws_ec2_ami
  instance_type          = var.aws_ec2_instance_type
  subnet_id              = var.aws_subnet_id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  key_name               = var.aws_key_name
  # availability_zone           = var.aws_az
  associate_public_ip_address = false

  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = false
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "Starting CubeAPM initialization..."
    sudo /bin/bash -c "$(curl -fsSL https://downloads.cubeapm.com/latest/install.sh)"
    echo "Initialization complete..."
  EOF

  user_data_replace_on_change = false

  tags = {
    Name = "cubeapm-instance"
  }
}
