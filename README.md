# Flutter POS アプリケーション

## 概要
Next.js版POSアプリケーションをFlutterで再実装したモバイルアプリケーション。

## 機能
- 商品検索（商品コード入力）
- 購入リスト管理
- 購入処理
- 税金計算・表示
- バーコードスキャン（段階的実装）

## 開発環境
- Flutter SDK 3.x以上
- Android Studio / VS Code
- Git

## セットアップ
1. リポジトリのクローン
2. 依存関係のインストール: `flutter pub get`
3. 実行: `flutter run`

## 実装手順
詳細な実装手順は `IMPLEMENTATION_CHECKLIST.md` を参照してください。

## API連携
- バックエンドAPI: `pos-app-backend`
- エンドポイント:
  - `GET /products/{code}` - 商品検索
  - `POST /purchase` - 購入処理

## 開発管理
- Git による細かなバージョン管理
- feature ブランチでの機能開発
- コミットメッセージ規約の遵守