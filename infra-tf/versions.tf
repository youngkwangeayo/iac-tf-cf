/*

Terraform이 실행될 최소 버전 조건을 지정합니다

*/

terraform {
    required_version = ">= 1.9.0" //테라폼 버전
    
    required_providers {    // 특정 벤더의 SDK
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.57"
      }
    }
}