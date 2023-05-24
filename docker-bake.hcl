# docker-bake.hcl
variable "TAG" { default = "latest" }
variable "PY_VER" { default = "3.9" }
variable "OS_VER" { default = "jammy" }
variable "BASE_DATE" { default = "20230328" }

group "default" {
  targets = [
    "carrunner",
    ]
}

target "carrunner" {
    dockerfile = "Dockerfile"
    target = "carrunner"
    args = {
      PY_VER = PY_VER,
      OS_VER = OS_VER,
      BASE_DATE = BASE_DATE
    }
    tags = [
      "docker.io/shermanm/carrunner:${PY_VER}-${OS_VER}-${BASE_DATE}-${TAG}"
      ]
    platforms = ["linux/arm64/v8"]
}
