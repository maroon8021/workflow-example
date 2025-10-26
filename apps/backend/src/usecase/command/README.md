# Command (UseCase)

POST, PATCH, PUT, DELETEリクエストの処理を担当する層。

## 特徴

- **データの変更を伴う**
- **Prisma Clientの直接実行は禁止**
- **必ずRepository経由でのデータ操作**
- ビジネスロジックの実行とトランザクション管理

## 配置するもの

- データ作成・更新・削除のロジック
- ビジネスルールの検証
- トランザクション処理

## 例

```
command/
├── createUser.ts
├── updateUser.ts
├── deleteUser.ts
└── publishPost.ts
```

## サンプルコード

```typescript
// createUser.ts
import { IUserRepository } from "../../domain/repositories/IUserRepository";
import { User } from "../../domain/entities/User";

export async function createUser(
  userRepository: IUserRepository,
  data: { email: string; name?: string }
) {
  // ビジネスロジック検証
  // ...

  // Repository経由でデータ操作
  const user = new User(data);
  return await userRepository.create(user);
}
```

## 重要な原則

- Prisma Clientへの直接アクセス禁止
- すべてのデータ操作はRepository interfaceを通じて行う
- ビジネスルールはDomain層のEntityやDomain Serviceで実装
