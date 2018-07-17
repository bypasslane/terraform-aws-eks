resource "local_file" "cluster-autoscaler" {
  content  = "${data.template_file.cluster-autoscaler.rendered}"
  filename = "${var.config_output_path}cluster-autoscaler.yaml"
}

resource "null_resource" "update_cluster_autoscaler" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${var.config_output_path}cluster-autoscaler.yaml --kubeconfig ${var.config_output_path}kubeconfig_${var.cluster_name}"
  }

  triggers {
    config_map_rendered = "${data.template_file.kubeconfig.rendered}"
  }
}

data "template_file" "cluster-autoscaler" {
  template = "${file("${path.module}/templates/cluster-autoscaler.yaml.tpl")}"

  vars {
    region        = "${data.aws_region.current.name}"
    cluster_name  = "${var.cluster_name}"
    version       = "v1.2.0"
    expander      = "least-waste"
  }
}
