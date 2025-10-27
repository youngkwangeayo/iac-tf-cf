#!/bin/bash

# ECS CloudFormation Deployment Script
# Usage: ./deploy.sh <environment> <solution> [service]
# Example: ./deploy.sh dev coffeezip cms

set -e

ENVIRONMENT=$1
SOLUTION=$2
SERVICE=$3

if [ -z "$ENVIRONMENT" ] || [ -z "$SOLUTION" ]; then
    echo "Usage: $0 <environment> <solution> [service]"
    echo "Example: $0 dev coffeezip cms"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/cf-templates"
VALUES_DIR="$SCRIPT_DIR/values"

# Stack naming convention
CLUSTER_STACK="ecs-cluster-${ENVIRONMENT}-${SOLUTION}"
TASKDEF_STACK="ecs-taskdef-${ENVIRONMENT}-${SOLUTION}-${SERVICE}"
SERVICE_STACK="ecs-service-${ENVIRONMENT}-${SOLUTION}-${SERVICE}"
AUTOSCALING_STACK="ecs-autoscaling-${ENVIRONMENT}-${SOLUTION}-${SERVICE}"

# Values file
if [ -n "$SERVICE" ]; then
    VALUES_FILE="$VALUES_DIR/ecs-${ENVIRONMENT}-${SOLUTION}-${SERVICE}.yaml"
else
    VALUES_FILE="$VALUES_DIR/ecs-${ENVIRONMENT}-${SOLUTION}.yaml"
fi

if [ ! -f "$VALUES_FILE" ]; then
    echo "Error: Values file not found: $VALUES_FILE"
    exit 1
fi

echo "=========================================="
echo "ECS Deployment Configuration"
echo "=========================================="
echo "Environment: $ENVIRONMENT"
echo "Solution: $SOLUTION"
echo "Service: ${SERVICE:-N/A}"
echo "Values File: $VALUES_FILE"
echo "=========================================="

# Function to parse YAML and extract parameters for CloudFormation
parse_yaml_to_params() {
    local section=$1
    local values_file=$2

    # Extract parameters from YAML section and convert to CloudFormation parameter format
    yq eval ".${section} | to_entries | map(\"ParameterKey=\" + .key + \",ParameterValue=\" + (.value | tostring))" "$values_file" -o json | \
        jq -r '.[]' | tr '\n' ' '
}

# Deploy Cluster
deploy_cluster() {
    echo ""
    echo ">>> Deploying ECS Cluster: $CLUSTER_STACK"

    CLUSTER_PARAMS=$(parse_yaml_to_params "Cluster" "$VALUES_FILE")

    aws cloudformation deploy \
        --stack-name "$CLUSTER_STACK" \
        --template-file "$TEMPLATES_DIR/ecs-cluster.yaml" \
        --parameter-overrides $CLUSTER_PARAMS \
        --tags \
            Environment="$ENVIRONMENT" \
            Solution="$SOLUTION" \
            ManagedBy=CloudFormation \
        --no-fail-on-empty-changeset

    echo "✓ Cluster deployed successfully"
}

# Deploy Task Definition
deploy_taskdef() {
    echo ""
    echo ">>> Deploying Task Definition: $TASKDEF_STACK"

    TASKDEF_PARAMS=$(parse_yaml_to_params "TaskDefinition" "$VALUES_FILE")

    aws cloudformation deploy \
        --stack-name "$TASKDEF_STACK" \
        --template-file "$TEMPLATES_DIR/ecs-taskdef.yaml" \
        --parameter-overrides $TASKDEF_PARAMS \
        --tags \
            Environment="$ENVIRONMENT" \
            Solution="$SOLUTION" \
            Service="$SERVICE" \
            ManagedBy=CloudFormation \
        --no-fail-on-empty-changeset

    echo "✓ Task Definition deployed successfully"
}

# Deploy Service
deploy_service() {
    echo ""
    echo ">>> Deploying ECS Service: $SERVICE_STACK"

    SERVICE_PARAMS=$(parse_yaml_to_params "Service" "$VALUES_FILE")

    aws cloudformation deploy \
        --stack-name "$SERVICE_STACK" \
        --template-file "$TEMPLATES_DIR/ecs-service.yaml" \
        --parameter-overrides $SERVICE_PARAMS \
        --tags \
            Environment="$ENVIRONMENT" \
            Solution="$SOLUTION" \
            Service="$SERVICE" \
            ManagedBy=CloudFormation \
        --no-fail-on-empty-changeset

    echo "✓ Service deployed successfully"
}

# Deploy Auto Scaling
deploy_autoscaling() {
    echo ""
    echo ">>> Deploying Auto Scaling: $AUTOSCALING_STACK"

    AUTOSCALING_PARAMS=$(parse_yaml_to_params "AutoScaling" "$VALUES_FILE")

    aws cloudformation deploy \
        --stack-name "$AUTOSCALING_STACK" \
        --template-file "$TEMPLATES_DIR/ecs-autoscaling.yaml" \
        --parameter-overrides $AUTOSCALING_PARAMS \
        --tags \
            Environment="$ENVIRONMENT" \
            Solution="$SOLUTION" \
            Service="$SERVICE" \
            ManagedBy=CloudFormation \
        --no-fail-on-empty-changeset

    echo "✓ Auto Scaling deployed successfully"
}

# Main deployment flow
main() {
    if [ -n "$SERVICE" ]; then
        # Full deployment with service
        deploy_cluster
        deploy_taskdef
        deploy_service
        deploy_autoscaling
    else
        # Only cluster deployment
        deploy_cluster
    fi

    echo ""
    echo "=========================================="
    echo "✓ Deployment completed successfully!"
    echo "=========================================="
    echo ""
    echo "Stack Names:"
    echo "  - Cluster: $CLUSTER_STACK"
    if [ -n "$SERVICE" ]; then
        echo "  - Task Definition: $TASKDEF_STACK"
        echo "  - Service: $SERVICE_STACK"
        echo "  - Auto Scaling: $AUTOSCALING_STACK"
    fi
    echo ""
}

main
