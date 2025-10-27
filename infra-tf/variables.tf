
/*
    항목                   자바 비유	                 설명
variable "region"	    private String region;	    외부에서 입력받을 수 있는 변수 선언
var.region	            this.region	                선언된 변수를 참조하는 구문
terraform.tfvars	    .properties 파일	          실제 값이 들어가는 곳
default	                기본값 설정                 	값이 주입되지 않았을 때 쓸 기본값

*/


# AWS 리전 (예: ap-northeast-2)
variable "region" {
  type        = string
  description = "AWS Region to deploy resources"
}

# AWS CLI 프로필명 (예: nextpay-prod)
variable "aws_profile" {
  type        = string
  description = "AWS CLI profile name for authentication"
}

# 프로젝트명 (예: nextpay)
variable "project" {
  type        = string
  default     = "nextpay"
  description = "Project name prefix for tagging and resource naming"
}

# 환경명 (예: prod, stage, dev)
variable "env" {
  type        = string
  default     = "prod"
  description = "Deployment environment (e.g., prod, stage, dev)"
}
