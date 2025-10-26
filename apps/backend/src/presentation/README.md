# Presentation Layer

HTTPリクエスト/レスポンスを扱う層。

## 配置するもの

- **Controller**: Honoのルートハンドラー、リクエストのバリデーション、レスポンスの整形
- **Middleware**: 認証、ログ、エラーハンドリングなど
- **Router**: ルーティング定義

## 例

```
presentation/
├── controllers/
│   ├── UserController.ts
│   └── PostController.ts
├── middlewares/
│   └── auth.ts
└── routes/
    └── index.ts
```
