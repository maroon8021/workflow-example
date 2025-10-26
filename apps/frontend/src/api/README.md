# API

TypeSpec/OpenAPIから生成されたAPIクライアントコードを配置。

## 構成

```
api/
├── generated/          # 自動生成されたコード（編集禁止）
│   ├── client.ts
│   ├── types.ts
│   └── endpoints.ts
└── client.ts           # APIクライアントの設定・カスタマイズ
```

## 使い方

```typescript
// features/users/api/userApi.ts
import { apiClient } from "@/api/client";

export async function fetchUsers() {
  return await apiClient.get("/users");
}
```

## 注意

- `generated/` 配下のファイルは自動生成されるため編集禁止
- カスタマイズが必要な場合は `client.ts` で設定を行う
