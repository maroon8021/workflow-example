# Backend Architecture

バックエンドはクリーンアーキテクチャを採用し、レイヤーを明確に分離しています。

## ディレクトリ構造

```
apps/backend/src/
├── infrastructure/     # 外部サービスを隠蔽、Repositoryの実装実態
├── presentation/       # Controller、ルーティング
├── domain/            # Entity、Repository interface
└── usecase/
    ├── query/         # GET - Prisma直接実行可
    └── command/       # POST/PUT/PATCH/DELETE - Repository経由のみ
```

## レイヤーの責務

### Domain Layer (`domain/`)

ビジネスロジックの中核。外部依存を持たない。

**配置するもの:**
- `entities/` - ビジネスロジックを持つドメインオブジェクト
- `repositories/` - Repository interface（実装はInfrastructure層）
- `services/` - エンティティに属さないビジネスロジック

**重要な原則:**
- Infrastructure層への依存禁止
- Prisma Clientへの直接アクセス禁止
- Repository interfaceのみを定義

**例:**
```typescript
// domain/repositories/IUserRepository.ts
export interface IUserRepository {
  findById(id: string): Promise<User | null>;
  create(user: User): Promise<User>;
  update(user: User): Promise<User>;
  delete(id: string): Promise<void>;
}

// domain/entities/User.ts
export class User {
  constructor(
    public readonly id: string,
    public email: string,
    public name?: string
  ) {}

  // ビジネスロジック
  updateEmail(newEmail: string) {
    // バリデーション
    if (!this.isValidEmail(newEmail)) {
      throw new Error("Invalid email");
    }
    this.email = newEmail;
  }

  private isValidEmail(email: string): boolean {
    // ...
  }
}
```

### Infrastructure Layer (`infrastructure/`)

外部サービスとの接続、Repository実装。

**配置するもの:**
- `repositories/` - Repository interfaceの具体的実装
- `database/` - Prisma Clientなどデータベース接続
- `external/` - 外部APIクライアントなど

**例:**
```typescript
// infrastructure/repositories/UserRepositoryImpl.ts
import { IUserRepository } from "../../domain/repositories/IUserRepository";
import { User } from "../../domain/entities/User";
import { PrismaClient } from "@prisma/client";

export class UserRepositoryImpl implements IUserRepository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string): Promise<User | null> {
    const data = await this.prisma.user.findUnique({ where: { id } });
    if (!data) return null;
    return new User(data.id, data.email, data.name ?? undefined);
  }

  async create(user: User): Promise<User> {
    const data = await this.prisma.user.create({
      data: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    });
    return new User(data.id, data.email, data.name ?? undefined);
  }

  // ...
}
```

### UseCase Layer (`usecase/`)

アプリケーションのユースケース。Query/Commandで分離。

#### Query (`usecase/query/`)

**目的:** 読み取り専用の処理（GET）

**特徴:**
- Prisma Clientの直接実行が可能
- パフォーマンス重視
- Repository不要

**例:**
```typescript
// usecase/query/getUserById.ts
import { PrismaClient } from "@prisma/client";

export async function getUserById(prisma: PrismaClient, id: string) {
  return await prisma.user.findUnique({
    where: { id },
    include: {
      posts: true,
    },
  });
}

// usecase/query/listUsers.ts
export async function listUsers(
  prisma: PrismaClient,
  { page = 1, limit = 20 }
) {
  const [users, total] = await Promise.all([
    prisma.user.findMany({
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: "desc" },
    }),
    prisma.user.count(),
  ]);

  return { users, total, page, limit };
}
```

#### Command (`usecase/command/`)

**目的:** データ変更を伴う処理（POST/PUT/PATCH/DELETE）

**特徴:**
- Prisma Clientの直接実行は禁止
- 必ずRepository経由
- ビジネスロジックの実行

**例:**
```typescript
// usecase/command/createUser.ts
import { IUserRepository } from "../../domain/repositories/IUserRepository";
import { User } from "../../domain/entities/User";

export async function createUser(
  userRepository: IUserRepository,
  data: { email: string; name?: string }
) {
  // ビジネスロジック検証
  // emailの重複チェックなど

  const user = new User(
    generateId(), // ID生成
    data.email,
    data.name
  );

  return await userRepository.create(user);
}

// usecase/command/updateUserEmail.ts
export async function updateUserEmail(
  userRepository: IUserRepository,
  userId: string,
  newEmail: string
) {
  const user = await userRepository.findById(userId);
  if (!user) {
    throw new Error("User not found");
  }

  // Entityのビジネスロジックを使用
  user.updateEmail(newEmail);

  return await userRepository.update(user);
}
```

### Presentation Layer (`presentation/`)

HTTPリクエスト/レスポンスの処理。

**配置するもの:**
- `controllers/` - ルートハンドラー
- `middlewares/` - 認証、ログ、エラーハンドリング
- `routes/` - ルーティング定義
- `validators/` - リクエストバリデーション

**例:**
```typescript
// presentation/controllers/UserController.ts
import { Context } from "hono";
import { getUserById } from "../../usecase/query/getUserById";
import { createUser } from "../../usecase/command/createUser";

export class UserController {
  constructor(
    private prisma: PrismaClient,
    private userRepository: IUserRepository
  ) {}

  async get(c: Context) {
    const id = c.req.param("id");
    const user = await getUserById(this.prisma, id);

    if (!user) {
      return c.json({ error: "User not found" }, 404);
    }

    return c.json(user);
  }

  async create(c: Context) {
    const body = await c.req.json();
    const user = await createUser(this.userRepository, body);
    return c.json(user, 201);
  }
}
```

## データフロー

### GET（クエリ）の場合

```
Request → Presentation (Controller)
         → UseCase/Query (Prisma直接実行)
         → Response
```

### POST/PUT/DELETE（コマンド）の場合

```
Request → Presentation (Controller)
         → UseCase/Command
         → Domain (Entity/Repository Interface)
         → Infrastructure (Repository実装)
         → Database (Prisma)
         → Response
```

## 依存関係ルール

```
Presentation → UseCase → Domain ← Infrastructure
                ↓
            (Query only: Prisma直接)
```

- **Presentation** は UseCase と Infrastructure に依存可
- **UseCase/Command** は Domain と Infrastructure に依存可
- **UseCase/Query** は Prisma に直接依存可
- **Domain** は何にも依存しない（純粋なビジネスロジック）
- **Infrastructure** は Domain に依存（interfaceを実装）

## 実装時の注意点

### Query実装時
- パフォーマンス重視でPrismaを直接使用
- 複雑なJOINやアグリゲーションもOK
- ビジネスロジックは含めない（単純なデータ取得のみ）

### Command実装時
- 必ずRepository経由でデータ操作
- ビジネスロジックはDomain層のEntityで実装
- トランザクションが必要な場合もRepository interfaceで抽象化

### Repository実装時
- Domain層のinterfaceを厳密に実装
- Prismaの型をそのまま返さず、Domain Entityに変換
- トランザクション処理はここで実装
