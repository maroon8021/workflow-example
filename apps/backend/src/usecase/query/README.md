# Query (UseCase)

GETリクエストの処理を担当する層。

## 特徴

- **読み取り専用**
- **Prisma Clientの直接実行が可能**
- パフォーマンスのため、Repository経由せず直接データベースアクセス可

## 配置するもの

- データ取得のためのクエリロジック
- 複数のテーブルをJOINした複雑なクエリ
- ページネーション、フィルタリング、ソートなど

## 例

```
query/
├── getUserById.ts
├── listUsers.ts
└── getPostsWithAuthor.ts
```

## サンプルコード

```typescript
// getUserById.ts
import { PrismaClient } from "@prisma/client";

export async function getUserById(prisma: PrismaClient, id: string) {
  return await prisma.user.findUnique({
    where: { id },
    include: { posts: true },
  });
}
```
