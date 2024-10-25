provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "master" { 
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [var.security_group_id]
  subnet_id = var.public_subnet_id
  key_name= var.key_pair_name
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 20
  }
  tags = {
    Name = "master"
  }



  provisioner "file" {
    source      = "./pfe-key.pem"
    destination = "/home/ubuntu/pfe-key.pem"
    
    connection {
      host = self.public_ip
      type = "ssh"
      user = "ubuntu"
      private_key = file("pfe-key.pem")
    } 
  }

 

  provisioner "file" {
    source      = "worker"
    destination = "/home/ubuntu/worker"
    
    connection {
      host = self.public_ip
      type = "ssh"
      user = "ubuntu"
      private_key = file("pfe-key.pem")
    }
  }


 provisioner "remote-exec" {
    inline = [
      "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
      "echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt update -y",
      "sudo apt install ansible fontconfig openjdk-17-jre jenkins podman -y",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",
      "sudo systemctl enable podman",
      "sudo systemctl start podman",
      "sudo ufw allow 22 && sudo ufw allow 8080",
      "sudo ip  a | grep 'inet' | grep 'eth0'|  awk '{print $2}'| cut -d '/' -f1 > ~/master", 
      "git clone https://github.com/chiheb-devops/k8s-install.git",
      "chmod +x /home/ubuntu/k8s-install/'k8s cluster'/inventory.sh",
      "chmod 400 /home/ubuntu/pfe-key.pem",
      "cd /home/ubuntu/k8s-install/'k8s cluster'",
      "./inventory.sh", 
      "chown ubuntu:ubuntu  -R /home/ubuntu/k8s-install",
      "ansible-playbook /home/ubuntu/k8s-install/'k8s cluster'/main.yaml"
    ]

    connection {
      host = self.public_ip
      type = "ssh"
      user = "ubuntu"
      private_key = file("pfe-key.pem")
    }
  }



depends_on = [aws_instance.worker]

 }

resource "local_file" "ip_master" {
      content  = aws_instance.master.private_ip
      filename = "master"
}

resource "aws_instance" "worker" { 
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [var.security_group_id]
  subnet_id = var.public_subnet_id
  key_name= var.key_pair_name
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 20
  }
   tags = {
    Name = "worker2"
  }
}

resource "local_file" "ip_worker" {
      content  = aws_instance.worker.private_ip
      filename = "worker"
}
