resource "kubernetes_namespace" "ns" { metadata { name = var.namespace } }


resource "helm_release" "argocd" {
  name = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = var.chart_version
  namespace = kubernetes_namespace.ns.metadata[0].name
  values = [file("${path.module}/values.yaml")]
}