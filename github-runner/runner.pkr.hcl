source "qemu" "github-runner" {
  vm_name          = "github-runner.img"
  headless         = true
  accelerator      = "kvm"
  format           = "qcow2"
  disk_compression = true
  disk_image       = true
  disk_size        = 5120
  disk_interface   = "virtio-scsi"
  disk_discard     = "unmap"
  net_device       = "virtio-net"

  output_directory = "output"

  iso_url      = "https://cloud-images.ubuntu.com/minimal/daily/focal/current/focal-minimal-cloudimg-amd64.img"
  iso_checksum = "file:https://cloud-images.ubuntu.com/minimal/daily/focal/current/SHA256SUMS"

  cd_files = ["./cloud-data/*"]
  cd_label = "cidata"

  ssh_username = "bot"
  ssh_password = "ubuntu"
  ssh_timeout  = "5m"
}

build {
  sources = ["source.qemu.github-runner"]

  provisioner "ansible" {
    playbook_file        = "provision.yml"
    user                 = "bot"
    inventory_directory  = "inventory"
    galaxy_file          = "requirements.yml"
    galaxy_force_install = true
    extra_arguments = [
      "-e", "skip_handlers=true"
    ]
  }

  post-processor "checksum" {
    checksum_types = ["sha256"]
    output         = "output/github-runner_SHA256SUMS"
  }
}
