# Infrastructure Layer

外部サービスを隠蔽し、Repositoryの実装実態を配置する層。

## 配置するもの

- **Repository実装**: Domain層で定義されたRepository interfaceの具体的な実装
- **External Services**: データベース、外部API、ファイルシステムなどへのアクセス
- **Prisma Client**: データベースアクセスの実装

## 例

```
infrastructure/
├── repositories/
│   ├── UserRepositoryImpl.ts
│   └── PostRepositoryImpl.ts
└── database/
    └── prisma.ts
```
