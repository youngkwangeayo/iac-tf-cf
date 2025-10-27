# ECS CloudFormation Templates

재사용 가능한 ECS Fargate CloudFormation 템플릿 및 자동 배포 시스템

> **Note**: Terraform 버전은 `../infra-tf/` 디렉토리를 참고하세요.

## 📁 디렉토리 구조

```
infra-cf/
├── cf-templates/              # CloudFormation 템플릿 (재사용)
│   ├── ecs-cluster.yaml      # ECS 클러스터
│   ├── ecs-taskdef.yaml      # Task Definition
│   ├── ecs-service.yaml      # ECS 서비스
│   └── ecs-autoscaling.yaml  # Auto Scaling
│
├── values/                    # 환경별 설정 파일
│   └── ecs-dev-coffeezip-cms.yaml
│
├── deploy.sh                  # 자동 배포 스크립트
└── README.md
```

## 🎯 네이밍 규칙

**스택 네이밍**: `{aws-service}-{environment}-{solution}[-{component}]`

### 예시
- **Cluster**: `ecs-cluster-dev-coffeezip`
- **Task Definition**: `ecs-taskdef-dev-coffeezip-cms`
- **Service**: `ecs-service-dev-coffeezip-cms`
- **Auto Scaling**: `ecs-autoscaling-dev-coffeezip-cms`

다른 솔루션 배포 시:
- `ecs-dev-mys1`
- `ecs-prod-payment`
- `ecs-staging-api`

## 🚀 빠른 시작

### 1. 새로운 솔루션 배포

```bash
# 1. Values 파일 복사 및 수정
cp values/ecs-dev-coffeezip-cms.yaml values/ecs-dev-mys1.yaml

# 2. 설정 파일 편집
vim values/ecs-dev-mys1.yaml

# 3. 배포 실행
./deploy.sh dev mys1 api
```

### 2. 기존 솔루션 업데이트

```bash
# Task Definition 이미지만 업데이트하고 재배포
vim values/ecs-dev-coffeezip-cms.yaml  # ContainerImage 수정
./deploy.sh dev coffeezip cms
```

## 📝 Values 파일 작성

`values/ecs-{environment}-{solution}-{service}.yaml` 형식으로 작성:

```yaml
# Cluster Parameters
Cluster:
  Environment: dev
  SolutionName: mys1
  CapacityProviders: "FARGATE,FARGATE_SPOT"

# Task Definition Parameters
TaskDefinition:
  Environment: dev
  SolutionName: mys1
  ServiceName: api
  ContainerImage: 365485194891.dkr.ecr.ap-northeast-2.amazonaws.com/mys1/api:1.0.0
  ContainerPort: 8080
  CPU: '512'
  Memory: '1024'
  EnvironmentVariables: |
    [
      {"name": "NODE_ENV", "value": "dev"},
      {"name": "PORT", "value": "8080"}
    ]

# Service Parameters
Service:
  Environment: dev
  SolutionName: mys1
  ServiceName: api
  ClusterStackName: ecs-cluster-dev-mys1
  TaskDefinitionStackName: ecs-taskdef-dev-mys1-api
  DesiredCount: 2
  TargetGroupArn: arn:aws:elasticloadbalancing:...
  ContainerName: mys1-api
  ContainerPort: 8080
  SubnetIds: "subnet-xxx,subnet-yyy"
  SecurityGroupIds: "sg-xxx,sg-yyy"

# Auto Scaling Parameters
AutoScaling:
  Environment: dev
  SolutionName: mys1
  ServiceName: api
  ClusterStackName: ecs-cluster-dev-mys1
  ServiceStackName: ecs-service-dev-mys1-api
  MinCapacity: 1
  MaxCapacity: 5
  TargetCPUUtilization: 70
```

## 🔧 고급 사용법

### AWS CLI로 직접 배포

```bash
# 1. Cluster
aws cloudformation deploy \
  --stack-name ecs-cluster-dev-mys1 \
  --template-file cf-templates/ecs-cluster.yaml \
  --parameter-overrides \
    Environment=dev \
    SolutionName=mys1

# 2. Task Definition
aws cloudformation deploy \
  --stack-name ecs-taskdef-dev-mys1-api \
  --template-file cf-templates/ecs-taskdef.yaml \
  --parameter-overrides \
    Environment=dev \
    SolutionName=mys1 \
    ServiceName=api \
    ContainerImage=xxx.dkr.ecr.xxx.amazonaws.com/mys1:1.0.0

# 3. Service
aws cloudformation deploy \
  --stack-name ecs-service-dev-mys1-api \
  --template-file cf-templates/ecs-service.yaml \
  --parameter-overrides \
    Environment=dev \
    SolutionName=mys1 \
    ServiceName=api \
    ClusterStackName=ecs-cluster-dev-mys1 \
    TaskDefinitionStackName=ecs-taskdef-dev-mys1-api \
    TargetGroupArn=arn:aws:elasticloadbalancing:...

# 4. Auto Scaling
aws cloudformation deploy \
  --stack-name ecs-autoscaling-dev-mys1-api \
  --template-file cf-templates/ecs-autoscaling.yaml \
  --parameter-overrides \
    Environment=dev \
    SolutionName=mys1 \
    ServiceName=api \
    ClusterStackName=ecs-cluster-dev-mys1 \
    ServiceStackName=ecs-service-dev-mys1-api
```

### 스택 삭제

```bash
# 역순으로 삭제
aws cloudformation delete-stack --stack-name ecs-autoscaling-dev-mys1-api
aws cloudformation delete-stack --stack-name ecs-service-dev-mys1-api
aws cloudformation delete-stack --stack-name ecs-taskdef-dev-mys1-api
aws cloudformation delete-stack --stack-name ecs-cluster-dev-mys1
```

## 🎨 템플릿 구조

### 1. ecs-cluster.yaml
- ECS 클러스터 생성
- Capacity Providers 설정 (FARGATE, FARGATE_SPOT)
- Container Insights 활성화

### 2. ecs-taskdef.yaml
- Task Definition 생성
- 컨테이너 설정 (이미지, 포트, 환경변수)
- Health Check 설정
- CloudWatch Logs 설정

### 3. ecs-service.yaml
- ECS 서비스 생성
- ALB Target Group 연결
- Network 설정 (VPC, Subnet, Security Group)
- Deployment 설정 (Circuit Breaker, Rolling Update)
- ECS Exec 활성화

### 4. ecs-autoscaling.yaml
- Application Auto Scaling 설정
- CPU 기반 Target Tracking Policy
- Scale In/Out Cooldown 설정

## 📊 스택 간 의존성

```
ecs-cluster
    ↓
ecs-taskdef
    ↓
ecs-service  ← (cluster, taskdef)
    ↓
ecs-autoscaling  ← (cluster, service)
```

## 🔐 필수 IAM 역할

- `ecsTaskRole`: Task가 AWS 리소스 접근 시 사용
- `ecsTaskExecutionRole`: ECR 이미지 pull, CloudWatch Logs 등
- `AWSServiceRoleForApplicationAutoScaling_ECSService`: Auto Scaling

## 💡 사용 팁

1. **환경별 분리**: dev, staging, prod 환경마다 별도의 values 파일 생성
2. **Secrets 관리**: 민감한 정보는 AWS Secrets Manager나 Parameter Store 사용
3. **Blue/Green 배포**: CodeDeploy와 통합 시 별도 템플릿 추가 고려
4. **모니터링**: CloudWatch Alarms와 Container Insights 활용

## 🐛 트러블슈팅

### Task가 시작되지 않을 때
```bash
# 서비스 이벤트 확인
aws ecs describe-services \
  --cluster ecs-dev-mys1 \
  --services service-dev-mys1-api \
  --query 'services[0].events[0:5]'

# Task 상태 확인
aws ecs describe-tasks \
  --cluster ecs-dev-mys1 \
  --tasks <task-id>
```

### Health Check 실패
- HealthCheckPath 확인
- Security Group 설정 확인
- HealthCheckGracePeriodSeconds 증가

## 🔄 IaC 도구 비교

### CloudFormation (현재)
- ✅ AWS 네이티브, 추가 설정 불필요
- ✅ Cross-Stack Reference로 의존성 관리
- ✅ IAM 권한 관리 간편
- ❌ AWS만 지원
- ❌ YAML/JSON 문법

### Terraform (대안)
- ✅ 멀티 클라우드 지원
- ✅ HCL 문법, 강력한 모듈 시스템
- ✅ `terraform plan`으로 변경 사항 미리 확인
- ❌ State 파일 관리 필요 (S3 + DynamoDB)
- ❌ AWS Provider 설정 필요

**Terraform 구현**은 `../infra-tf/` 디렉토리에서 확인하세요.

## 📚 참고 문서

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [CloudFormation ECS Reference](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/AWS_ECS.html)
- [Application Auto Scaling](https://docs.aws.amazon.com/autoscaling/application/userguide/)
- [프로젝트 개요](../INFO.md) - 전체 IaC 템플릿화 프로젝트 정보
