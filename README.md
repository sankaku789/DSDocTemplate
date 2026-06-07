# DSDocTemplate

デジタル庁デザインシステムの考え方を、Typst のレポート・仕様書向けに落とし込んだドキュメントテンプレートです。

読みやすい本文、明確な見出し階層、十分なコントラスト、8px基準の余白スケール、表・注記・コードリストなど、文書作成でよく使う要素をまとめています。

## ファイル構成

- `main.typ`: 実際の文書作成に使う最小テンプレートです。
- `sample.typ`: 表示確認・デバッグ用の長いサンプル文書です。
- `config.typ`: レイアウト、色、余白、補助関数を定義しています。
- `config.yaml`: 文書メタ情報、フォント、ヘッダー/フッター設定を変更します。
- `hayagira.yaml`: 外部ツール連携用の設定ファイルです。

## 使い方

1. `config.yaml` の `document-meta` を編集します。
2. `main.typ` の本文を差し替えます。
3. PDF を生成します。

```sh
typst compile main.typ
```

表示確認やデバッグには `sample.typ` を使います。

```sh
typst compile sample.typ
```

## 設定

`config.yaml` の主な項目です。

```yaml
document-meta:
  title: "ドキュメントタイトル"
  subtitle: "デジタル庁デザインシステム準拠テンプレート"
  author: ["作成者名"]
  affiliation: "所属・プロジェクト名"
  date: auto

document-setting:
  columns: 1
  heading-numbering: "1.1 "
  show-header: true
  show-footer: true
```

`date` は `auto` の場合、コンパイル日を使います。固定したい場合は `2026-06-08` のように `YYYY-MM-DD` で指定します。

## 最小例

```typ
#import "config.typ":*

#show: setup.with()

#docCover([
  #summaryBox([文書の要点を書きます。])
])

= 概要

本文を書きます。

#callout([確認してほしい内容を書きます。], kind: "info", title: "補足")
```

## 主な関数

- `docCover(body, title: ..., subtitle: ..., status: ...)`: 表紙を生成します。`status` は指定した場合だけ表示されます。
- `summaryBox(body, title: ...)`: 文書冒頭の概要枠を作ります。
- `callout(body, kind: "info" | "success" | "warning" | "danger", title: ...)`: 注記枠を作ります。
- `kpi(label, value, note: ...)`: 指標カードを作ります。
- `codeList(code, caption: ...)`: `codelst` を使った行番号付きコードリストを作ります。
- `includeSrc(filepath: ..., lang: ..., caption: ...)`: 外部ソースファイルをリストとして掲載します。
- `includePDF(file)`: 既存PDFを差し込みます。

## 方針

- フォントはサンセリフを基本にし、読みやすさを優先します。
- キーカラー、ニュートラルカラー、セマンティックカラーを紙面向けに使用します。
- 本文は行間を広めに取り、両端揃えを避けます。
- 余白はデジタル庁デザインシステムの 8px 基準を PDF 向けに換算して使います。
- 色だけに依存せず、罫線、ラベル、余白でも意味を伝えます。

## フォント

既定では、この環境で安定して使える `Noto Sans`、`IPAexGothic`、`Noto Sans Mono` を指定しています。別環境でフォント警告が出る場合は、利用可能なフォントを確認して `config.yaml` を変更してください。

```sh
typst fonts
```

## 参照元

- デジタル庁デザインシステムβ版: https://design.digital.go.jp/
- デジタル庁デザインシステム デザイントークン: https://github.com/digital-go-jp/design-tokens
