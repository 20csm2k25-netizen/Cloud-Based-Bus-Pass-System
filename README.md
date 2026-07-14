# RouteWise

Cloud-native bus ticket booking platform MVP.

## Stack
- TypeScript / Node.js
- AWS
- Docker
- Kubernetes
- Terraform
- Postgres
- Redis
- SQS

## Repo Layout
- `apps/web` - customer-facing frontend
- `services/auth-service` - signup, login, JWT, refresh
- `services/catalog-service` - routes, operators, buses, schedules
- `services/search-service` - search and availability snapshot
- `services/booking-service` - seat holds, confirms, tickets
- `services/payment-service` - payment intents and webhooks
- `services/notification-service` - email/SMS notifications
- `packages/shared` - shared types and utilities
- `infra/terraform` - AWS infrastructure
- `k8s` - Kubernetes manifests or Helm chart

## Current Status
This workspace has been scaffolded for Phase 1. Service implementations, migrations, infra, and frontend are still pending.
