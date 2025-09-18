resource "kubernetes_namespace" "ns" {
  metadata { name = var.namespace }
}

resource "helm_release" "jenkins" {
  name = "jenkins"
  repository = "https://charts.jenkins.io"
  chart = "jenkins"
  namespace = var.namespace
  create_namespace = false
  version = var.chart_version != "" ? var.chart_version : null
  values = [file("${path.module}/values.yaml")]

  depends_on = [kubernetes_namespace.ns]
}
