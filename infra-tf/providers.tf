/*

자바의 import com.aws.sdk.*; 글로벌 임포트
Terraform에게 “이 코드는 AWS용이다”를 알려주는 선언이에요.

Terraform은 Provider를 통해 각 클라우드와 통신합니다.
AWS, Azure, GCP, Kubernetes 등 각각 Provider를 통해 동작하죠.

*/

provider "aws" {
  region  = var.region
  profile = var.aws_profile

  # 모든 리소스에 공통 태그 적용 (비필수지만 실무에선 필수 수준)
  default_tags {
    tags = {
      Project = var.project
      Env     = var.env
      Owner   = "platform"
      Managed = "terraform"
    }
  }
}
