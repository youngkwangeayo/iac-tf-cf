# IaC 템플릿화 프로젝트  

## 목표
AWS ECS 인프라를 재사용 가능한 IaC 템플릿으로 구성하여, 다양한 솔루션을 빠르게 배포할 수 있도록 함

## 네이밍 규칙
**형식**: `{aws-service}-{environment}-{solution}[-{component}]`

### 예시
- `ecs-dev-myapp`
- `ecs-dev-mys1-api`
- `ecs-prod-payment-web`
- `rds-dev-myapp`

## 디렉토리 구조

```
ecs-templates/
├── dev/                    # 실제 AWS describe로 생성된 참고 파일
│   ├── cluster-dev.json
│   ├── taskdef-dev.json
│   ├── service-dev.json
│   └── autoscal-dev.json
│
├── infra/                  # CloudFormation 템플릿 (구현 완료)
│   ├── cf-templates/       # 재사용 가능한 템플릿
│   │   ├── ecs-cluster.yaml
│   │   ├── ecs-taskdef.yaml
│   │   ├── ecs-service.yaml
│   │   └── ecs-autoscaling.yaml
│   ├── values/             # 환경별 설정 파일
│   │   └── ecs-dev-myapp-cms.yaml
│   ├── deploy.sh           # 배포 스크립트
│   └── README.md           # 사용 가이드
│
└── infra-tf/               # Terraform 템플릿 (예정)
    ├── modules/            # 재사용 모듈
    │   ├── ecs-cluster/
    │   ├── ecs-task/
    │   ├── ecs-service/
    │   └── ecs-autoscaling/
    ├── environments/       # 환경별 설정
    │   └── dev/
    │       └── myapp/
    │           ├── main.tf
    │           ├── variables.tf
    │           └── terraform.tfvars
    └── README.md

```

## IaC 도구 비교

### CloudFormation
- **장점**: AWS 네이티브, 추가 설정 불필요, Cross-Stack Reference
- **단점**: YAML/JSON 작성, AWS만 지원
- **상태**: ✅ 구현 완료

### Terraform
- **장점**: 멀티 클라우드 지원, HCL 문법, 강력한 모듈 시스템, Plan 기능
- **단점**: State 관리 필요 (S3 + DynamoDB)
- **상태**: 🔄 구현 예정

## 사용 시나리오

### 새로운 솔루션 배포
1. Values/환경 파일 복사
2. 설정 수정 (이미지, 포트, 환경변수 등)
3. 배포 실행

### CloudFormation 방식
```bash
cp infra/values/ecs-dev-myapp-cms.yaml infra/values/ecs-dev-mys1.yaml
vim infra/values/ecs-dev-mys1.yaml
./infra/deploy.sh dev mys1 api
```

### Terraform 방식 (예정)
```bash
cp -r infra-tf/environments/dev/myapp infra-tf/environments/dev/mys1
vim infra-tf/environments/dev/mys1/terraform.tfvars
cd infra-tf/environments/dev/mys1
terraform init
terraform plan
terraform apply
```

## 다음 단계
- [ ] Terraform 모듈 구현
- [ ] Terraform 환경별 설정 생성
- [ ] 배포 스크립트 작성
- [ ] CI/CD 파이프라인 통합