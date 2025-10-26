# Domain Layer

ビジネスロジックの中核となる層。外部依存を持たない。

## 配置するもの

- **Entity**: ビジネスロジックを持つドメインオブジェクト
- **Repository Interface**: データ永続化の抽象インターフェース（実装はInfrastructure層）
- **Value Object**: 値オブジェクト
- **Domain Service**: エンティティに属さないビジネスロジック

## 例

```
domain/
├── entities/
│   ├── User.ts
│   └── Post.ts
├── repositories/
│   ├── IUserRepository.ts
│   └── IPostRepository.ts
└── services/
    └── UserDomainService.ts
```

## 重要な原則

- Infrastructure層への依存は禁止
- Prisma Clientへの直接アクセス禁止
- Repository interfaceのみを定義し、実装はInfrastructure層で行う
