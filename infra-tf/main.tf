
# 실제 코드의 시작점 (리소스 진입부)

# 현재 AWS 계정 정보 가져오기
data "aws_caller_identity" "current" {}

# 현재 AWS 리전 정보 가져오기
data "aws_region" "current" {}

# 출력용 (outputs.tf로 빼도 되지만 지금은 main에서 바로 테스트)
output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_region_name" {
  value = data.aws_region.current.name
}

resource "aws_s3_bucket" "terraform-s3" {
  bucket = "${var.project}-${var.env}-terraform-demo-bucket"
  force_destroy = true
  
  tags = {
    "Name" = "${var.project}-${var.env}-terraform-demo"
  }
}