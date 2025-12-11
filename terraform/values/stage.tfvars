project_id = "terraform-test-480809"
region     = "europe-west3"
environment = "stage"

# VPC Network configuration
vpc_name            = "app-vpc"
vpc_cidr            = "10.1.0.0/16"
public_subnet_cidr  = "10.1.1.0/24"
private_subnet_cidr = "10.1.2.0/24"
enable_nat_gateway  = true

# Database configuration
zone = "europe-west3-a"
postgres_user = "postgres"
postgres_password = "SecureStagePass2024!"

# SSH Configuration - Add your SSH public keys here
ssh_public_keys = [
  # Key 1 - Ivan Kaliuzhnyi key
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQComcHlqFA07D+lkidiX+hXPhqH8WFDQG7h2M/j1xfOkYug4pD56+DoMBSUUhxfE/nUKa3UrBsOFetWLhgi5zi9H94tOMifh9EPjsVVofrZeTViM+xJ9X6Xo9dqPxAWK7brrw2nhOBb/cvdU3uf74b3X6zL8YuQbXliZzC1EBwUCafqOo0bbmCMoMUFx3gX2P0pRpjGs/aM6UA6e8RdQMwMqDQCztZlPSmjSOV+86V6YbzXxkbFtrNReq7+AZNPraUgead9aJ7Xyqxt/pZ1ukYyNvkYAbcWslneoQLaGkMmSbdNMAOeSmxnEY59rIDUn2hIpjVTnqVZNx8jvvJhkqBAOhkeI/whG8jfxEvcltQ8Y9F+mGjfG1yUJSneKZdkQjwgl9D5QBlxVpJDrfgMCNIADIVf9j+i68DG5jCotzU77ju1oWlCZe8htJ6lh+j4fe2c0w9qUsSbaXGvnag/Bnh47Ks9Vw69upf9hfwPoVBXUnSQYsz5NIIVhenziUubHks= kaliuzhnyi@DESKTOP-0RK1DLO",
  
  # Key 2 - Yevhen Naumchyk key
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD8UbWO76dkDoNymT7Tb7afBG2Cu1kHqNhQMBCDM6FPN5eJlKwsQq3pb5clkp4TcJjIcpVEsIouYuQExOys6Jgw9pTp+NjPW8oNFFuozX+5INlOPKQU/dcFeOBRKHz0ObXzF8JVcCPPWjzpdfw912/hQsllSNISxX8EjPqbr94RU5R64thqrWck0zlx8kJLvClCRBelGwXj5HqPS5hnzA1/29ua4tJ4/RSl8mEzmPCg+8IIpol+yzxHpFj9iiuLRxO6uap4AIS3HcemcprxuEdA0WOGld10cycp3M1D/uJhC+9XKAGWwmlqPg7PW3bxVf1EgI6K0w3F2cbYqso3wazwOCYrNsBwhlvgk19xxNu5ZPLWFRBg68GFAuXuRKzieN4KkrvNtu09uJGeB+PkvB3A33sL5aC9w0zNDTUE/vTlG2ZAzQ+cwkKmKm/nfIRLELHVlVvOPcgA+5Yp0zkZ14Tg9Whc9Qm40aqkptzeFpFSFaXU0FO733P4LrWeQyMijdok8H7xH8GXBLf15dmMm5yEtfV27bWLMIg4JGizrTzd/aMCJviCeIClDr1SoIoTSqLzKxoELxPlQM8PsORDD5uooJlRjUdpjsRw34p+n9h+wc6b6LkDlUoj/MhKxONwcziFQKayT214F2NbXCQ1yvtgjJv4hq8zoLv+I8zWtCFCPQ== gerty438@gmail.com",
  
  # Key 3 - Yuliia Ivanchuk key
  # "ssh-rsa ...",
  
  # Key 4 - Marta Hentosh key
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXFvRMI7cF+Tk/uGOtnpuegNqXIwQ1qks0E8T4gK9c0WQVom3YImWEwk8BF4ORxpgrM5mhYQqA79eAZmlU1fChN2hB2KldLJQdi/2CbYONTB8ghI4x4QUdk1aSQZ9llxpUYZW4Za9jaxie+JNrXot01xP998brm2LYAn3il3jx8QGjT7c73BZa5Hy7WY34ck+4l9aJJdo2qOmQbvISJgcB+8Dpw2FD5pKusXahMVc3rWNDtTcoStSt9xbQZpdRZHIr+tWkDwxZrcBbrugzTWJHX2BNMI53uTsWZ5PqlguCT4Fwg4AOMZAo8l1jWBhHIBA8+6tEmn2H8v8Vwyo+MrvEfl6oLa2T2QR7xCpmj6ntYOjx18TciUBlxTiihUgpEV3Qc1b/KdbkJ6Vlubc8a4P0xXsbNbKR2QYWVXadqCTBdWXyoaLSqtATih1AHO0udDgsN2/5O/CQatJMcPXp0Cg5slwkjXBhjt7HofPv98M0smhKxSGUiBTBrxgTQWIu31Y0XCtf4nemKgS2RAi6lTZHNTOw71mgx1M1RZyrqc1UivwDXcU9dcqc5dY/asTQDkAhib1p0P6fiC1hzterUKQf/BmWNRHrrcXHPdM5uDJgDNExA9swhpvUQ1ZbGlIGrScFt+itFdAA0DTE0j5dhZ7MW5KIBqCSV18ROw+4Xfz7hQ== ubuntu"
]

db = {
  name         = "postgres-db"
  machine_type = "e2-micro"
  public_ip    = false
  tags         = ["database", "postgres"]
  docker_image = "postgres:13"  
  port         = 5432
  os_image     = "debian-cloud/debian-11"
  disk_size_gb = 20
  postgres_db  = "appdb"
}

# VM Instances configuration
vm_instances = [
  {
    name         = "bastion-host"
    machine_type = "e2-micro"
    zone         = "europe-west3-a"
    subnet       = "public"
    public_ip    = true
    tags         = ["bastion"]
    ports        = [22]
    os_image     = "debian-cloud/debian-11"
    disk_size_gb = 10
  },
  {
    name         = "web-server-1"
    machine_type = "e2-micro"
    zone         = "europe-west3-a"
    subnet       = "public"
    public_ip    = true
    tags         = ["web", "frontend"]
    ports        = [80, 443]
    os_image     = "debian-cloud/debian-11"
    disk_size_gb = 10
  },
  {
    name         = "app-server-1"
    machine_type = "e2-micro"
    zone         = "europe-west3-b"
    subnet       = "private"
    public_ip    = false
    tags         = ["app", "backend"]
    ports        = [3000]
    os_image     = "debian-cloud/debian-11"
    disk_size_gb = 15
  }
]